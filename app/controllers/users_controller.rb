class UsersController < ApplicationController
  #load_and_authorize_resource

  before_action :authenticate_user!

  def home
    @user = current_user
    add_breadcrumb 'Мой профиль', :authenticated_root_url
  end

  def show
    @user = User.find(params[:id])
    add_breadcrumb 'Пользователи', :users_url
    add_breadcrumb @user.full_name, :user_url
  end

  def index
    @users = User.paginate(page: params[:page], per_page: 10)
    add_breadcrumb 'Пользователи', :users_url
  end

  def students
    student = Role.find_by(name: 'Студент')
    @students = student.users.paginate(page: params[:page], per_page: 10)
    add_breadcrumb 'Пользователи', :users_url
    add_breadcrumb 'Студенты', :students_url
  end

  def new
    @user = User.new
    add_breadcrumb 'Пользователи', :users_url
    add_breadcrumb 'Новый пользователь', :new_user_url
  end

  def create
    @user = User.new(user_params)
    add_roles(@user)

    if @user.save
      flash[:success] = 'Пользователь успешно создан'
      redirect_to @user
    else
      flash[:danger] = 'Вы ввели некорректные данные, проверьте и попробуйте снова'
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    add_breadcrumb 'Пользователи', :users_url
    add_breadcrumb 'Редактирование данных пользователя - ' + @user.full_name
  end

  def update
    @user = User.find(params[:id])
    if @user.has_role? 'Администратор'
      add_roles(@user)
    end

    if @user.update(user_params)
      if @user == current_user
        redirect_to authenticated_root_url
      else
       redirect_to @user
      end
        flash[:success] = 'Данные пользователя успешно обновлены'
    else
      flash[:danger] = 'Вы ввели некорректные данные, проверьте и попробуйте снова'
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])

    @user.destroy
    flash[:success] = 'Пользователь успешно удален'
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:name, :surname, :birthdate, :gender, :passport_data, :photo, :passport_scan_copy,
                                 :email, :password, group_ids: [], role_ids: [],
                                 contact_attributes: [:id, :phone, :additional_phone, :skype])
  end

  def add_roles(user)
    user.roles = []
    params[:user][:role_ids].each do |r|
      user.roles.push(Role.find(r)) unless r.blank?
    end
  end
end
