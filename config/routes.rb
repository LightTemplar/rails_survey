require 'sidekiq/web'
RailsSurvey::Application.routes.draw do
  devise_for :users
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web, at: 'sidekiq', as: 'sidekiq'
  end
  ActiveAdmin.routes(self)

  concern :paginatable do
    get '(page/:page)', action: :index, on: :collection, as: ''
  end
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      namespace :frontend do
        resources :projects do
          resources :instruments, only: [:index, :show] do
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
        resources :instruments, only: [:index, :show]
        resources :device_users, only: [:index, :show]
        resources :questions, only: [:index, :show]
        resources :options, only: [:index, :show]
        resources :randomized_factors, only: [:index, :show]
        resources :randomized_options, only: [:index, :show]
        resources :question_randomized_factors, only: [:index, :show]
        resources :images, only: [:index, :show]
        resources :surveys, only: [:create]
        resources :responses, only: [:create]
        resources :response_images, only: [:create]
        resources :sections, only: [:index, :show]
        resources :android_updates, only: [:index, :show]
        resources :skips, only: [:index, :show]
        resources :rules, only: [:index]
        resources :device_sync_entries, only: [:create]
        resources :grids, only: [:index, :show]
        resources :grid_labels, only: [:index, :show]
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

  root to: 'projects#index'
  get 'home/privacy'
  resources :projects do
    resources :score_schemes do
      member do
        get 'score/:survey_id', action: 'score', as: 'score'
      end
    end
    resources :scores
    resources :instruments do
      member do
        get :csv_export
        get :pdf_export
        get :translation_template_export
        get :export_responses
        get :move
        get :copy
        get :copy_questions
        get :questions
        match :update_move, action: :update_move, via: [:patch, :put]
        match :update_copy, action: :update_copy, via: [:patch, :put]
      end
      resources :instrument_translations do
        member do
          get :show_pdf
        end
        collection do
          get :new_gt
        end
        collection do
          post :import_translation
        end
      end
      resources :versions, only: [:index, :show]
      resources :sections
      resources :grids
      resources :randomized_factors
      resources :reorder_questions, only: [:index] do
        collection do
          post :reorder
        end
      end
    end

    member do
      get :instrument_export
    end

    resources :rules
    resources :device_users
    resources :responses
    resources :surveys, concerns: :paginatable do
      collection do
        get 'instrument_surveys/:instrument_id', action: :instrument_surveys, as: 'instrument'
      end
      member do
        get :identifier_surveys
      end
    end
    resources :notifications, only: [:index]
    resources :devices, only: [:index, :show] do
      resources :device_sync_entries, only: [:index]
    end
    resources :response_images, only: [:show]
    resources :graphs, only: [:index]
    resources :response_exports do
      member do
        # get :project_responses_long
        # get :project_responses_wide
        # get :project_responses_short
        get :instrument_responses_long
        get :instrument_responses_wide
        get :instrument_responses_short
        get :project_response_images
        get :instrument_response_images
      end
    end
    get :export_responses
    get 'graphs/daily/' => 'graphs#daily_responses'
    get 'graphs/hourly/' => 'graphs#hourly_responses'
    resources :metrics do
      resources :stats do
        collection do
          get :crunch
        end
      end
    end
    resources :rosters do
      resources :surveys
    end
  end
  resources :request_roles, only: [:index]
  get '/photos/:id/:style.:format', controller: 'api/v1/frontend/images', action: 'show'
  get '/pictures/:id/:style.:format', controller: 'response_images', action: 'show'
  get 'home/privacy'
  resources :android_updates, only: [:index, :show]
end
