# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  namespace :api, defaults: { format: 'json' } do
    namespace :v4 do
      post 'user_token' => 'user_token#create'
      resources :instruments, only: :index
      resources :projects do
        resources :instruments do
          resources :sections
          resources :displays do
            resources :display_instructions
          end
          resources :instrument_questions do
            resources :next_questions
            resources :multiple_skips
            resources :loop_questions
          end
          resources :score_schemes do
            resources :domains
            resources :subdomains do
              resources :score_units do
                resources :option_scores
              end
            end
          end
          member do
            get :reorder
            get :pdf_export, defaults: { format: 'pdf' }
          end
        end
      end
      resources :question_sets do
        resources :folders do
          resources :questions, controller: 'folder_questions'
        end
        resources :questions, controller: 'question_set_questions'
        collection do
          get :total
        end
      end
      resources :option_sets do
        resources :option_in_option_sets
      end
      resources :instructions
      resources :options
      resources :questions, only: [:index]
      resources :option_translations
      resources :instruction_translations
      resources :question_translations
      resources :surveys do
        resources :responses
      end
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

    namespace :v1 do
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
end
