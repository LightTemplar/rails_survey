# frozen_string_literal: true

require 'sidekiq/web'
RailsSurvey::Application.routes.draw do
  devise_for :users
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web, at: '/admin/sidekiq', as: 'sidekiq'
  end
  ActiveAdmin.routes(self)

  concern :paginatable do
    get '(page/:page)', action: :index, on: :collection, as: ''
  end
  namespace :api, defaults: { format: 'json' } do
    namespace :v4 do
      devise_scope :user do
        post 'login' => 'sessions#create'
        delete 'logout' => 'sessions#destroy'
      end
      resources :instruments, only: :index
      resources :projects do
        resources :instruments do
          resources :sections
          resources :displays
          resources :instrument_questions
          resources :score_schemes do
            resources :domains
            resources :subdomains do
              resources :score_units do
                resources :option_scores
              end
            end
          end
        end
      end
      resources :question_sets do
        resources :folders do
          resources :questions, controller: 'folder_questions'
        end
      end
      resources :option_sets do
        resources :option_in_option_sets
        collection do
          get :total
        end
      end
      resources :instructions
      resources :options
      resources :questions, only: [:index]
      resources :option_translations
      resources :surveys
    end

    namespace :v3 do
      resources :projects, only: :index do
        resources :instruments, only: :index
        resources :sections, only: :index
        resources :instructions, only: :index
        resources :questions, only: :index
        resources :options, only: :index
        resources :option_in_option_sets, only: :index
        resources :randomized_factors, only: :index
        resources :randomized_options, only: :index
        resources :question_randomized_factors, only: :index
        resources :device_users, only: %i[index create]
        resources :images, only: %i[index show]
        resources :rules, only: :index
        resources :score_schemes, only: :index
        resources :score_units, only: :index
        resources :option_scores, only: :index
        resources :score_unit_questions, only: :index
        resources :android_updates, only: %i[index show]
        resources :option_sets, only: :index
        resources :displays, only: :index
        resources :next_questions, only: :index
        resources :multiple_skips, only: :index
        resources :condition_skips, only: :index
        resources :follow_up_questions, only: :index
        resources :display_instructions, only: :index
        resources :validations, only: :index
        resources :loop_questions, only: :index
        resources :critical_responses, only: :index
        resources :surveys, only: :create
        resources :responses, only: :create
        resources :response_images, only: :create
        resources :device_sync_entries, only: :create
        resources :rosters, only: :create
        resources :scores, only: :create
        resources :raw_scores, only: :create
        member do
          get :current_time
        end
      end
    end
    namespace :v2 do
      resources :question_sets do
        resources :questions, controller: 'question_set_questions' do
          member do
            get :copy
          end
          resources :critical_responses
        end
        resources :folders
      end
      resources :option_sets do
        resources :options, controller: 'option_set_options'
        resources :option_set_translations
        member do
          get :copy
        end
      end
      resources :option_in_option_sets
      resources :questions
      resources :question_translations, only: %i[index create update show] do
        collection do
          post :batch_update
        end
      end
      resources :question_back_translations, only: %i[index create update show] do
        collection do
          post :batch_update
        end
      end
      resources :instructions
      resources :instruction_translations, only: %i[index create update] do
        collection do
          post :batch_update
        end
      end
      resources :options
      resources :option_translations, only: %i[index create update] do
        collection do
          post :batch_update
        end
      end
      resources :option_back_translations, only: %i[index create update] do
        collection do
          post :batch_update
        end
      end
      resources :rules
      resources :validations
      resources :validation_translations, only: %i[index create update] do
        collection do
          post :batch_update
        end
      end
      resources :projects do
        member do
          post :import_instrument
        end
        collection do
          post :v1_v2_import
        end
        resources :instruments do
          resources :instrument_questions do
            resources :next_questions
            resources :multiple_skips
            resources :follow_up_questions
            resources :condition_skips
            resources :loop_questions
          end
          resources :displays do
            member do
              get :copy
              get :tabulate
              post :move
            end
            resources :display_instructions
          end
          resources :instrument_translations
          resources :instrument_rules
          resources :sections
          resources :section_translations do
            collection do
              post :batch_update
            end
          end
          resources :display_translations do
            collection do
              post :batch_update
            end
          end
          member do
            get :copy
            get :set_skip_patterns
            get :tabulate
            post :reorder
            post :reorder_displays
            post :to_pdf
          end
          resources :next_questions, controller: 'instrument_next_questions'
        end
      end
      get 'settings/index'
    end
    namespace :v1 do
      namespace :frontend do
        resources :projects do
          resources :instruments, only: %i[index show] do
            resources :questions, concerns: :paginatable do
              resources :question_translations, only: [:update]
              member do
                post :copy
              end
              resources :options do
                resources :skips
                resources :option_translations, only: [:update]
              end
              resources :images
              resources :question_randomized_factors
            end
            resources :sections do
              resources :section_translations, only: [:update]
            end
            resources :grids do
              resources :grid_labels
            end
            resources :randomized_factors do
              resources :randomized_options
            end
            resources :instrument_translations do
              resources :grid_translations
              resources :grid_label_translations
            end
          end
          resources :score_schemes do
            resources :score_units do
              member do
                get :questions
              end
              collection do
                get :options
                get :score_types
                get :question_types
              end
              resources :option_scores
            end
          end
          get 'graphs/daily/' => 'graphs#daily'
          get 'graphs/hourly/' => 'graphs#hourly'
          get 'graphs/count/' => 'graphs#count'
        end
      end

      resources :projects do
        resources :instruments, only: %i[index show]
        resources :device_users, only: %i[index show]
        resources :questions, only: %i[index show]
        resources :options, only: %i[index show]
        resources :randomized_factors, only: %i[index show]
        resources :randomized_options, only: %i[index show]
        resources :question_randomized_factors, only: %i[index show]
        resources :images, only: %i[index show]
        resources :surveys, only: [:create]
        resources :responses, only: [:create]
        resources :response_images, only: [:create]
        resources :sections, only: %i[index show]
        resources :android_updates, only: %i[index show]
        resources :skips, only: %i[index show]
        resources :rules, only: [:index]
        resources :device_sync_entries, only: [:create]
        resources :grids, only: %i[index show]
        resources :grid_labels, only: %i[index show]
        resources :rosters, only: [:create]
        resources :score_schemes, only: [:index]
        resources :score_units, only: [:index]
        resources :score_unit_questions, only: [:index]
        resources :option_scores, only: [:index]
        resources :scores, only: [:create]
        resources :raw_scores, only: [:create]
        member do
          get :current_time
        end
      end
    end
  end

  resources :projects, only: %i[index show] do
    resources :instruments, only: [:show]
  end

  # resources :projects do
  #   member do
  #     get :instrument_export
  #   end
  #   collection do
  #     get :question_sets
  #   end
  #   resources :score_schemes do
  #     member do
  #       get 'score/:survey_id', action: 'score', as: 'score'
  #     end
  #   end
  #   resources :scores
  #   resources :instruments do
  #     member do
  #       get :csv_export
  #       get :pdf_export
  #       get :translation_template_export
  #       get :export_responses
  #       get :move
  #       get :copy
  #       get :copy_questions
  #       get :questions
  #       match :update_move, action: :update_move, via: %i[patch put]
  #       match :update_copy, action: :update_copy, via: %i[patch put]
  #     end
  #     resources :instrument_translations do
  #       member do
  #         get :show_pdf
  #       end
  #       collection do
  #         get :new_gt
  #       end
  #       collection do
  #         post :import_translation
  #       end
  #     end
  #     resources :versions, only: %i[index show]
  #     resources :sections
  #     resources :grids
  #     resources :randomized_factors
  #     resources :reorder_questions, only: [:index] do
  #       collection do
  #         post :reorder
  #       end
  #     end
  #   end
  #
  #   resources :rules
  #   resources :device_users
  #   resources :responses
  #   resources :surveys, concerns: :paginatable do
  #     collection do
  #       get 'instrument_surveys/:instrument_id', action: :instrument_surveys, as: 'instrument'
  #     end
  #     member do
  #       get :identifier_surveys
  #     end
  #   end
  #   resources :notifications, only: [:index]
  #   resources :devices, only: %i[index show] do
  #     resources :device_sync_entries, only: [:index]
  #   end
  #   resources :response_images, only: [:show]
  #   resources :graphs, only: [:index]
  #   resources :response_exports do
  #     member do
  #       # get :project_responses_long
  #       # get :project_responses_wide
  #       # get :project_responses_short
  #       get :instrument_responses_long
  #       get :instrument_responses_wide
  #       get :instrument_responses_short
  #       get :project_response_images
  #       get :instrument_response_images
  #     end
  #   end
  #   # get :export_responses
  #   get 'graphs/daily/' => 'graphs#daily_responses'
  #   get 'graphs/hourly/' => 'graphs#hourly_responses'
  #   resources :metrics do
  #     resources :stats do
  #       collection do
  #         get :crunch
  #       end
  #     end
  #   end
  #   resources :rosters do
  #     resources :surveys
  #   end
  # end
  # resources :request_roles, only: [:index]
  # resources :android_updates, only: %i[index show]
  #
  # get '/photos/:id/:style.:format', controller: 'api/v1/frontend/images', action: 'show'
  # get '/pictures/:id/:style.:format', controller: 'response_images', action: 'show'
  # get 'home/privacy'

  root to: 'projects#index'
  # Handled by AngularJS
  get '*path' => 'projects#index'
end
