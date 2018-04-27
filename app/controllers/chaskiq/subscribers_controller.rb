require_dependency "chaskiq/application_controller"

module Chaskiq
  class SubscribersController < ApplicationController

    before_action :find_base_models

    layout "chaskiq/empty"

    def show
      #TODO, we should obfustate code
      find_subscriber
      render "edit"
    end

    def new
      @subscriber = @campaign.subscribers.new
    end

    def edit
      find_subscriber
    end

    def update
      find_subscriber
      if @subscriber.update_attributes(resource_params) && @subscriber.errors.blank?
        flash[:notice] = "you did it!"
        @subscription.subscribe! unless @subscription.subscribed?
        redirect_to campaign_path(@campaign)
      else
        render "edit"
      end
    end

    def create
      @subscriber = @campaign.list.create_subscriber(resource_params)
      if @subscriber.errors.blank?
        @subscription = @campaign.subscriptions.find_by(subscriber: @subscriber)
        @subscription.subscribe! unless @subscription.subscribed?
        flash[:notice] = "you did it!"
        redirect_to campaign_path(@campaign)
      else
        render "new"
      end
    end

    def delete
      find_subscriber
    end

    def destroy
      find_subscriber
      begin
        if @subscription.unsubscribe!
          flash[:notice] = "Thanks, you will not receive more emails from this newsletter!"
          redirect_to campaign_path(@campaign)
        end
      rescue
        flash[:notice] = "Thanks, you will not receive more emails from this newsletter!"
        redirect_to campaign_path(@campaign)
      end
    end


  protected

    def find_subscriber
      @subscriber = @campaign.list.subscribers.find_by(email: URLcrypt.decode(params[:id]))
      @subscription = @campaign.subscriptions.find_by(subscriber: @subscriber)
    end

    def find_base_models
      @campaign = Chaskiq::Campaign.find(params[:campaign_id])
      @list = @campaign.list
    end


    def resource_params
      return [] if request.get?
      params.require(:subscriber).permit(:email, :name, :last_name)
    end

  end
end
