class Admin::OrdersController < ApplicationController
  layout "admin"
  include AdminHelper

  def index
    @orders = get_orders
    @orders = @orders.where(:checkout_date => nil) if filter_by_unplaced?
    @orders = @orders.limit(100)
  end

  def show
    @order = Order.value_per_order.find(params[:id])
    @order_contents = @order.order_contents.includes(:product)
  end

  def new
    @user = User.find(params[:user_id])
    @order = @user.orders.build
    @address_options = @user.addresses.map{ |a| [full_address(a), a.id] }
    @credit_card_options = credit_card_options(@user.credit_cards)
  end

  def create
    @user = User.find(order_params[:user_id])
    @order = @user.orders.build(order_params)
    # Will not accept order without those addresses specified and
    # valid (belong to that user)
    if @user.address_ids.include?(order_params[:shipping_id].to_i) &&
       @user.address_ids.include?(order_params[:billing_id].to_i)
      # if @user.orders.where(:checkout_date => nil).count > 1
      #   flash[:danger] = "Failed to create order. Only one unplaced order is allowed."
      #   @address_options = @user.addresses.map{ |a| [full_address(a), a.id] }
      #   @credit_card_options = credit_card_options(@user.credit_cards)
      #   render :new
      if @order.save
        flash[:success] = "Order created successfully"
        redirect_to edit_admin_order_path(@order.id)
      else
        @address_options = @user.addresses.map{ |a| [full_address(a), a.id] }
        @credit_card_options = credit_card_options(@user.credit_cards)
        flash[:danger] = "Failed to create order"
        render :new
      end
    else
      # set remaining vars for `new` view
      @address_options = @user.addresses.map{ |a| [full_address(a), a.id] }
      @credit_card_options = credit_card_options(@user.credit_cards)
      flash.now[:danger] = "The specified addresses must belong to you"
      render :new
    end
  end

  def edit
    @order = Order.find(params[:id])
  end


  # ------------------------------------------------------------------------
  # Helpers
  # ------------------------------------------------------------------------

  def get_orders
    # Filter addresses by user, if provided
    if params[:user_id]
      if User.exists?(params[:user_id])
        # The view is cutomized based on the presence of the `@user` var
        @user = User.find(params[:user_id])
        Order.value_per_order.where(:user_id => @user.id)
      else
        flash[:warning] = "The user_id #{params[:user_id]} does not exist"
        false
      end
    else
      Order.value_per_order
    end
  end

  def filter_by_unplaced?
    if params[:status]
      params[:status].to_sym == :unplaced
    end
  end

  def order_params
    params.require(:order).permit(
    :user_id, :shipping_id, :billing_id, :credit_card_id)
  end

end
