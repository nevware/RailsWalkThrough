class TimesheetPolicy
  attr_reader :user, :timesheet
  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(assignment: :person).where(people: {email: user.email})
      end
    end

    private

    attr_reader :user, :scope
  end

  def initialize(user, timesheet)
    @user = user
    @timesheet = timesheet
  end

  def update?
    user.admin? or not post.published?
  end
end