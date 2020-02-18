# frozen_string_literal: true

ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, project_ids: [], role_ids: []

  action_item :new_invitation, only: :index do
    link_to 'Invite New User', new_user_invitation_path
  end

  collection_action :new_invitation do
    @user = User.new
    render 'new', layout: 'active_admin'
  end

  collection_action :send_invitation, method: :post do
    @user = User.invite!(user_params, current_user)
    if @user.errors.empty?
      flash[:success] = 'User has been successfully invited.'
      redirect_to admin_users_path
    else
      messages = @user.errors.full_messages.map { |msg| msg }.join
      flash[:error] = 'Error: ' + messages
      redirect_to new_user_invitation_path
    end
  end

  index do
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    actions
  end

  show do |user|
    attributes_table do
      row :id
      row :email
      row 'Roles' do
        user.roles.each do |role|
          li { role.name }
        end
      end
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_ip
      row :created_at
      row :updated_at
      row 'User Projects' do
        ul do
          user.projects.each do |project|
            li { project.name }
          end
        end
      end
    end

    active_admin_comments
  end

  form do |f|
    f.inputs 'User Details' do
      f.input :email
      f.input :password, hint: 'Leave blank. Do not change.'
      f.input :password_confirmation
      if current_user.admin?
        f.input :projects, as: :check_boxes, collection: Project.all
        f.input :roles, as: :check_boxes, collection: Role.where.not(name: 'super_admin')
      end
    end
    f.actions
  end

  controller do
    def update
      @user = User.find(params[:id])
      if params[:user].blank? || params[:password].blank? || params[:password_confirmation].blank?
        @user.update_without_password(user_params)
      else
        @user.update_attributes(user_params)
      end
      if @user.errors.blank?
        redirect_to admin_user_path(params[:id]), notice: 'User updated successfully.'
      else
        render :edit
      end
    end

    private

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, project_ids: [], role_ids: [])
    end
  end
end
