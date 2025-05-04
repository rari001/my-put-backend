class SessionsController < DeviseTokenAuth::SessionsController
  def destroy
    guest = current_user if current_user&.guest?

    super do |_resource|
      guest&.destroy!
    end
  end
end
