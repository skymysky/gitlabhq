# Projects::HousekeepingService class
#
# Used for git housekeeping
#
# Ex.
#   Projects::HousekeepingService.new(project).execute
#
module Projects
  class HousekeepingService < BaseService
    include Gitlab::ShellAdapter

    LEASE_TIMEOUT = 3600

    def initialize(project)
      @project = project
    end

    def execute
      if !try_obtain_lease
        return "Housekeeping was already triggered in the past #{LEASE_TIMEOUT / 60} minutes"
      end
      
      GitlabShellWorker.perform_async(:gc, @project.path_with_namespace)
      return "Housekeeping successfully started"
    end

    private

    def try_obtain_lease
      lease = ::Gitlab::ExclusiveLease.new("project_housekeeping:#{@project.id}", timeout: LEASE_TIMEOUT)
      lease.try_obtain
    end
  end
end
