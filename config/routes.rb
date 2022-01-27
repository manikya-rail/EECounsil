Rails.application.routes.draw do

  get 'users/index'
  get 'users/:id/profile', to: 'users#profile', as: :user_profile
  get 'users/:id/update_user_status', to: 'users#update_user_status'
  get 'users/:id/update_approval_status', to: 'users#update_approval_status'
  get 'users/:id/delete_profile', to:'users#delete_profile'
  get 'users/:id/delete_therapist', to: 'users#delete_therapist'
  get 'users/:id/check_schedule', to: 'users#check_schedule'
  mount ActionCable.server => '/cable'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
  }

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth', controllers: {
        token_validations:  'api/v1/token_validations',
        registrations:      'api/v1/registrations',
        sessions:           'api/v1/sessions',
        passwords:          'api/v1/passwords'
      }
      post '/check_for_email/', controller: 'users', action: :check_for_email
      post '/check_for_promo/', controller: 'users', action: :check_for_promo
      post '/check_for_url/', controller: 'users', action: :check_for_url
      patch '/update_url/', controller: 'users', action: :update_url
      post '/update_user_against_therapist/', controller: 'users', action: :update_user_against_therapist
      post '/update_user_device/', controller: 'users', action: :update_user_device
      post 'request_demo' => 'schedules#request_demo'
      get '/messages/notifications' => 'messages#notifications'
      get '/get_patient_detail' => 'messages#get_patient_detail'
      post '/media_notes' => 'messages#media_notes'
      get '/fetch_documents' => 'messages#fetch_documents'

      post '/videos/create_meeting' => 'therapists#create_meeting'

      get '/procedure_codes' => 'schedules#fetch_procedures'
      get '/fetch_uncharged_schedules' => 'schedules#fetch_uncharged_schedules'
      get '/fetch_time_zones' => 'users#fetch_time_zones'

      get '/diagnosis_codes' => 'notes#fetch_diagnosis_codes'
      get '/risk_factors' => 'notes#fetch_risk_factors'
      get '/interventions' => 'notes#fetch_interventions'
      get '/fetch_all_notes' => 'notes#fetch_all_notes'
      post '/attach_files_for_notes' => 'notes#attach_files_for_notes'
      delete '/delete_file_note' => 'notes#delete_file_note'
      get '/fetch_file_for_note' => 'notes#fetch_file_for_note'
      get '/fetch_draft_notes' => 'notes#fetch_draft_notes'
      get '/fetch_used_schedules' => 'schedules#fetch_used_schedules'
      post '/create_diagnosis_code' => 'notes#create_diagnosis_code'
      get '/payers_list' => 'insurance#payers_list'
      get '/patient_eligibility' => 'insurance#patient_eligibility'
      get '/schedules_list' => 'insurance#schedules_list'
      get '/claim_form_info' => 'insurance#claim_form_info'
      post '/create_patient_claim' => 'insurance#create_patient_claim'
      get '/validate_and_submit_claim' => 'insurance#validate_and_submit_claim'
      get '/claim_status' => 'insurance#claim_status'
      post '/update_pre_amount' => 'insurance#update_pre_amount'

      resources :schedules do
        get 'get_schedule', to: 'schedules#get_schedule'
        put :cancel ,:book ,:complete
        resources :messages, except: :destroy do
          collection do
            post :video_call
            post :end_call
            post :note_on_video_call
          end
        end
        get '/:video_call_id/note_messages', action: :note_messages
        collection do
          get 'electronic_notes/:patient_id/:therapist_id', action: :electronic_notes
          get 'get_users_shared_notes/:patient_id/:therapist_id/:role', action: :get_users_shared_notes
          post :save_note, action: :save_note
          post :save_user_notes, action: :save_user_notes
        end
        match "messages", to: "messages#destroy", via: "delete", defaults: { id: nil }
      end
      resources :stripe do
        collection do
          post :create_customer
          post :list_sources
          post :subscribe_plan
          post :create_source
          post :detach_source
          post :change_sefault_source
          post :subscription_history
          post :upgrade_plan
          post :get_invoice
        end
      end
      resource :questionnaire_answers, only: :create
      resources :packages, only: :index
      resources :slots
      resources :plans, only: [:index,:show]
      resources :consent_forms, only: [:index,:show] do
        collection do
          get :fetch_client_consent_form
        end
      end

      get 'availablities/:id/get_clone_of_availablity', to: 'availablities#get_clone_of_availablity'
      resources :therapists, only: [] do
        get 'get_available_days', to: 'availablities#get_available_days'
        resources :availablities, only: [:create, :destroy]
      end

      resources :availablities, only: [] do
        resources :unavailabilities, only: [:create, :update, :destroy]
      end
      resources :stripe_webhooks, only: [] do
        collection do
          post 'webhook', to: 'stripe_webhooks#webhook'
        end
      end

      resources :patient_packages, only: [:create, :new, :index]
      post 'cancel_subscription', controller: :therapist_packages, action: :cancel_subscription
      resources :therapist_packages, only: [:index]
      get 'questionnaire_answers/patient_answers', to: 'questionnaire_answers#patient_answers'
      resources :skills, only: [:index]
      resources :questionnaires, only: [:index]
      resources :blogs, only: [:index]
      resources :videos, only: [:index]
      get 'blogs/categories', to: 'blogs#categories'
      resources :users, only: [] do
        member do
          get 'others_profile/', to: 'users#others_profile'
          get 'profile/', to: 'users#profile', as: :user_profile
          get 'my_patients/', to:'users#my_patients'
          get 'my_therapists/', to:'users#my_therapists'
          get 'payment_details/', to:'users#payment_details'
          get 'patient_charges_details/', to:'users#patient_charges_details'
          get 'update_status/', to:'users#update_user_status'
          get 'get_timezone/', to: 'users#get_timezone'
          get 'check_therapist_cc_feature/', to: 'users#check_therapist_cc_feature'
        end
        collection do
          post 'unscheduled_chat/', to:'users#unscheduled_chat'
          post 'get_patient_detail/', to:'users#get_patient_detail'
          post 'create_manual_charge/', to:'users#create_manual_charge'
          post 'approve_charge/', to:'users#approve_charge'
          post 'refund_charge/', to:'users#refund_charge'
          post 'get_users_detail_with_schedules/', to:'users#get_users_detail_with_schedules'
          get 'get_bank_details/', to:'users#get_bank_details'
          get 'search_therapist/', to:'users#search_therapist'
          get 'check_patient_card_details', to: 'users#check_patient_card_details'
          post 'get_therapist_introductory_video/', to:'users#get_therapist_introductory_video'
          post 'create_connect_account/', to: 'users#create_connect_account'
          get 'payout_details', to:'users#payout_details'
        end
      end
      resources :courses, only: [:index]
      get 'courses/get_therapist_course_sessions', to: 'courses#get_therapist_course_sessions'
      resources :therapist_courses, only: [:create,:index] do
        collection do
          post :use_trail
        end
      end
      resources :patients, only: [] do
        member do
          get :therapist_default_rate
        end
      end

      namespace :notes do
        resources :simple_notes, :standard_notes, :diagnosis_treatment_notes
      end

      resources :therapists, only: [:show] do
        member do
          post :invite_patients
          put :update_patient_default_rate
          post :create_meeting
          post :create_zoom_user
          get :zoom_meeting_status
          get :zoom_end_meeting
        end
      end
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html'

  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
    get 'new_patient', to: 'users/registrations#new_patient', as: :new_patient
    get 'new_therapist', to: 'users/registrations#new_therapist', as: :new_therapist
    post 'create_patient', to: 'users/registrations#create_patient', as: :create_patient
    post 'create_therapist', to: 'users/registrations#create_therapist', as: :create_therapist
    get 'users/:id/edit_profile', to: 'users/registrations#edit_profile', as: :edit_profile
    get 'users/:id/show', to: 'users/registrations#show', as: :show
    patch 'users/:id/update_profile', to: 'users/registrations#update_profile', as: :update_profile
    get 'users/:id/show_profile', to: 'users/registrations#show_profile', as: :show_profile
  end
  get 'states/:country', to: 'application#states'
  get 'cities/:state', to: 'application#cities'
  get 'courses/delete_coursesession_media', to: 'courses#delete_coursesession_media'
  resources :questionnaires
  resources :packages
  resources :procedure_codes, :diagnosis_codes, :risk_factors, :interventions, :consent_forms

  resources :plans , controller: :payment_plans do
    collection do
      post 'block/:id',   action: :block
      post 'unblock/:id', action: :unblock
    end
  end

  resources :skills
  resources :categories
  resources :blogs
  resources :courses do
    member do
      get 'show_course', to: "courses#show_course"
    end
  end
  resources :course_sessions
  resources :schedules
  resources :therapists
  resources :payers
  resources :service_codes
  resources :videos
  resources :service_codes
  resources :locations, only: [:index]
  root "home#index"
  post '/promo_codes/sent_promos_to_therapists' => 'promo_codes#sent_promos_to_therapists'
  resources :promo_codes do
    member do
      get 'promos_for_therapists'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
