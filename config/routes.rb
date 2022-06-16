Rails.application.routes.draw do

  # Devise Routes / Authentication routes
  devise_for :contacts, path: 'contact_users', controllers: { passwords: 'contacts/passwords', sessions: 'contacts/sessions' }
  devise_for :users, controllers: { registrations: 'registrations', passwords: 'passwords', sessions: 'users/sessions' }
  namespace :users do
    resource :two_factor_authentication, controller: 'two_factor_authentication', only: [:new, :show, :create] do
      collection do
        get :resend_direct_otp
      end
    end
  end
  namespace :users do
    resources :tfa_phone_numbers, only: [:index, :new, :create, :destroy]
  end


  # Engine Routes
  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end
  mount Ckeditor::Engine => '/ckeditor'
  mount ActionCable.server => '/cable'

  # Application Routes
  get 'authorize' => 'auth#gettoken'
  get 'mail/index'

  get 'home/index'
  get 'google_autication' => 'google_imap#authentication'
  get 'oauth2callback' => 'google_imap#callback'
  get 'get_access_code' => 'google_imap#get_access_code'

  get 'home/dashboard'
  resources :work_flows do
    collection do
      post 'builder'
      post 'action_builder'
    end
  end
  resources :companies do
    get 'logo_image'
    delete 'remove_logo'
  end
  resources :search
  resources :user_permissions
  namespace :contacts do
    root 'home#dashboard'
    resources :projects do
      member do
        get 'overview'
        get 'accept_contact_invitation'
        get 'project_details'
      end
      collection do
      end
      resources :messages do
        delete 'comment_delete'
      end
      resources :project_documents
    end
    # resources :messages
    resources :contacts do
      delete 'remove_image'
      patch 'upload_image'
      get 'new_image'
      patch 'phone_update'
      get 'company_edit'
      patch 'company_update'
      collection do
        patch 'client_update/:id', to: 'contacts#client_update', as: 'client_update'
      end
    end
    resources :tickets do
      member do
        get 'overview'
      end
      resources :messages do
        get 'reply_edit'
        patch 'reply_update'
        delete 'reply_delete'
      end
      resources :ticket_documents
    end
    #resources :ticket_documents
    resources :invoices
    resources :inventories
    resources :messages
    resources :directories do
      collection do
        delete :destroy_all
        get 'system_files'
      end
    end
    resources :documents do
      collection do
        delete :destroy_all
        get 'upload_document'
        get 'update_documents'
        get 'selected_documents'
      end
    end
    post 'uploadfiles'=>'documents#upload'
  end

  get 'contacts/dashboard' => 'contacts/home#dashboard'

  get 'settings/index'
  post 'uploadfiles'=>'documents#upload'

  resources :leads do
    resources :comments, only: [:create, :update,:index]
    #resources :tasks
    collection do
      delete 'destroy_all'
      get 'import_leads'
      post 'import_map'
      get 'assign_all', to: 'leads#new_assign_all'
      post 'assign_all'
    end
    member do
      get 'convert_client'
      get 'edit_summary'
    end
  end
  post 'import_file' => 'leads#import_file'
  get 'import_form' => 'leads#import_form'
  resources :contacts do
    collection do
      get 'check_email'
      get 'resend_invitation'
      get 'lead_contacts'
      get 'client_contacts'
      get 'vendor_contacts'
      delete 'destroy_all'
    end
  end

  resources :project_tasks
  get 'search_auto_complete_data_tasks' => 'project_tasks#search_auto_complete_data_tasks', :as => "search_auto_complete_data_tasks"
  resources :projects do
    collection do
      delete 'destroy_all'
      get 'user_list'
      get 'list'
      post 'send_project_invitaiton'
      get 'project_user_list'
    end
    member do
      get 'overview'
      get 'invite_for_project'
      get 'project_details'
      get 'accept_user_invitation'
    end
    resources :messages do
      delete 'comment_delete'
    end
    resources :project_documents
  end

  get 'project_communication_dashborad' => 'projects#project_communication_dashborad', as: :project_communication_dashborad
  get "back_to_project/:id" => "projects#back_to_project", as: :back_to_project

  resources :messages
  resources :tickets do
    collection do
      delete 'destroy_all'
      get 'contacts_list'
      get 'user_list'
      get 'list'
      post 'send_ticket_invitaiton'
      get 'ticket_user_list'
      get 'reports'
      post 'download_attachment', to: 'tickets#download_attachment', as: :download_attachment
    end
    member do
      get 'overview'
      get 'invite_for_ticket'
      get 'ticket_details'
    end
    resources :messages do
      delete 'comment_delete'
      get 'reply_edit'
      patch 'reply_update'
      delete 'reply_delete'
    end
    resources :ticket_documents
  end

  get 'autocomplete_data' => 'tickets#autocomplete_data', :as => "autocomplete_data_tickets"
  get 'back_to_ticket/:id' => 'tickets#back_to_ticket', as: :back_to_ticket


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#dashboard'
  resources :settings do
    collection do
      get 'module', as: :module
      get 'actions'
      get 'users_settings', as: :users
      get 'module_select'
      get 'email'
      get 'revoke_mail_access'
      resources :users do
        delete 'remove_image'
        get 'signature'
        patch 'update_signature'
        patch 'upload_image'

        get 'resend_invitation'
      end
      get 'new_image' => 'users#new_image'
      resources :roles
    end
  end
  resources :groups do
    collection do
      get :change_position
    end
  end
  resources :fields do
    collection do
      get :change_position
      patch :change_position_in_table
      patch :change_header_view
      patch :toggle_visible_in_table
    end
    member do
      patch :change_properties
    end
  end
  resources :field_picklist_values do
    collection do
      get :change_klass
      get :change_field
      get :change_position
    end
  end
  resources :custom_values
  get '/dashboard', to: 'home#dashboard'

  resources :clients do
    resources :comments, only: [:create,:update,:index]
    resources :inventory_associations, module: :clients, only: [:index] do
      collection do
        get :subcategories
        get :inventory_groups
        get :inventory_group
        get :inventory_groups_by_sku
        get :bulk_new
        post :bulk_create
      end
    end
    resources :shipments, module: :clients, only: [:new, :create] do
      get 'package_label/:id', to: 'shipments#package_label', as: :package_label
    end
    resources :employees, module: :clients do
      member do
        get 'feedback'
      end
    end
    collection do
      delete :destroy_all
      get 'import_clients'
      post 'import_map'
      get 'select_client'
      get 'status_board'
      post 'update_status_board'
      get 'department_details'
      get :client_by_merchant_id
    end
    post 'set'
    member do
      get 'edit_summary'
      get 'send_menu_approval_email'
      get 'send_menu_approval_sms'
      get 'logs'
    end
  end
  post 'import_file_client' => 'clients#import_file_client'
  get 'import_form_client' => 'clients#import_form_client'

  resources :vendors do
    member do
      get 'edit_summary'
    end
    collection do
      delete :destroy_all
    end
  end


  get 'page1', to: 'home#page1'
  get 'project_communication_dashborad1', to: 'home#project_communication_dashborad1'
  resources :module_numbers
  get 'page2', to: 'home#page2'
  get "get_module_name" => "module_numbers#get_module_name"
  get 'privacy', to: 'home#privacy'
  get 'view_map', to: 'home#view_map'

  resources :invoices do
    collection do
      delete :destroy_all
      get :inventories
      get :clients
    end
    get 'email'
    post 'email_create'
    get 'preview'
    get 'download'
    resource :payment, except: [:edit, :update, :destroy]
  end

  resources :directories do
    collection do
      delete 'destroy_all'
      get 'system_files'
    end
  end
  resources :documents do
    collection do
      delete :destroy_all
      get 'upload_document'
      get 'update_documents'
      get 'selected_documents'
    end
  end

  resources :tasks do
    collection do
      delete :destroy_all
    end
    post :mark_as_completed
  end
  get 'back_to_task/:id', to: 'tasks#back_to_task', as: :back_to_task

  resources :notes do
    collection do
      delete :destroy_all
    end
  end
  get 'back_to_note/:id', to: "notes#back_to_note", as: :back_to_note
  resources :roles
  resources :emails do
    post :reply
    collection do
      get :sent
      get :draft
      get :connect
      get :update_draft
      get :create_draft
      delete 'destroy_draft/:id', to: 'emails#destroy_draft', as: 'destroy_draft'
    end
  end

  namespace :purchase_order do
    resources :devices, only: [:index, :new, :edit, :create, :update, :destroy]
    resources :products, only: [:index, :new, :edit, :create, :update, :destroy]
    resources :versions, only: [:show, :create]
  end

  resources :inventory_groups do
    collection do
      patch :setup_inventory_versions
      delete :destroy_all
      get :subcategories_for_category
    end
  end

  # Category Management
  resources :categories, only: [:index, :new, :edit, :create, :update, :destroy]
  resources :subcategories, only: [:new, :edit, :create, :update, :destroy]

  resources :inventories do
    collection do
      delete :destroy_all
      get :import
      post :import_map
      put :update_inventory_column
      get :subcategories_for_data_list
      post :import_file
    end
    member do
      get :logs
    end
  end

  resources :stock_adjustments, except: %i[index show]
  resources :email_templetes do
    collection do
      delete 'destroy_all'
    end
  end
  resources :template_dirs
  resources :cemails do
    collection do
      delete 'destroy_all'
    end
  end
  get "get_template" => "cemails#get_template", as: :get_template
  get "back_to_email/:id" => "cemails#back_to_email", as: :back_to_email

  resources :invoice_taxes
  resources :feedback_questions
  resources :feedbacks, only: [:create] do
    collection do
      get :employee
      post :send_otp
      post :verify_otp
    end
  end

  resources :meetings do
    collection do
      delete :destroy_all
      get :calendar
      get :calendar_meetings
      post :calendar_day_meetings
    end
  end

  namespace :project_management do
    resources :projects do
      collection do
        get :list
        get :contacts_form
      end
      resources :tasks, except: [:index] do
        resources :comments, only: [:index, :create, :destroy]
      end
    end
  end

  namespace :public do
    resources :help_desks, only: [:index, :show]
    resources :clients, only: [:edit, :update] do
      member do
        get :status
      end
    end
  end

  resources :help_desks

  namespace :contract do
    resources :templates
    resources :contracts
  end

  resources :kpis, only: [:index] do
    collection do
      get :sales
      post :sales_lead_contracts_pipeline
      post :sales_lead_status
      post :won_clients
      get :marketing
      post :marketing_lead_statistics
      get 'account_manager_performance'
    end
  end

  namespace :file_manager do
    resources :file_associations, only: [:edit, :update, :destroy] do
      collection do
        get :bulk_new
        post :bulk_create
      end
    end
    resources :files, only: [] do
      collection do
        post :bulk_create
        get :selected_files
      end
    end
  end

  resources :reports, only: [:index] do
    collection do
      get 'deployment'
      get 'ipos_login_details'
    end
  end

  resources :ipos_marketing_tools

  # User::TimeSheet routes
  resources :users, module: :users, only: [] do
    resources :time_sheet_logs, except: [:show] do
      collection do
        get 'clock_in_out_toggle'
      end
    end
    collection do
      get 'time_sheet_logs/all_users'
      get 'time_sheet_logs/settings'
      post 'time_sheet_logs/update_settings'
    end
  end

  namespace :third_party do
    get 'sso', to: 'sso#create'
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :tasks, only: [:index] do
        collection do
          put 'update_task'
          post 'clear_data'
        end
      end
      resources :user_task_logs, only: [] do
        collection do
          put 'checkin'
          put 'checkout'
        end
      end
      resources :employees, only: [:index, :create, :destroy] do
        collection do
          post 'employee_create'
        end
      end
    end
  end
end
