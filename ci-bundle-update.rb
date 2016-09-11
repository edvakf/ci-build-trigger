require 'circleci'

class CiBundleUpdate
  def initialize(circleci_token, exec_days)
    CircleCi.configure do |config|
      config.token = circleci_token
    end

    @exec_days = exec_days
  end

  def build(username, reponame, branch)
    if skip?
      puts "This build was skipped for $EXEC_DAYS (#{exec_days})"
      return
    end

    response = CircleCi::Project.build_branch(
      username, reponame, branch, {},
      build_parameters: { BUNDLE_UPDATE: true }
    )

    if response.success?
      puts "This build was succeeded"
    else
      puts "This build was failed for #{response.body}"
    end
  end

  private

  attr_reader :exec_days

  def skip?
    exec_days &&
      ! exec_days.split(',').include?(Time.now.strftime('%a'))
  end
end

if $0 == __FILE__
  ci_bundle_update = CiBundleUpdate.new(ENV['CIRCLECI_TOKEN'], ENV['EXEC_DAYS'])
  ci_bundle_update.build(ENV['GITHUB_USERNAME'], ENV['GITHUB_REPONAME'], ENV['BRANCH'])
end
