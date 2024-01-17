# frozen_string_literal: true

module FlyHii
  # Maps over local and remote git repo infrastructure
  class TranslateRepo
    class Errors
      NoTranslateTextFound = Class.new(StandardError)
      # TooLargeToClone = Class.new(StandardError)
      # CannotOverwriteLocalGitRepo = Class.new(StandardError)
    end

    def initialize(remote_id, translatedtext)
      @remote_id = remote_id
      @translatedtext = translatedtext
      # remote = Git::RemoteGitRepo.new(@project.http_url)
      # @local = Git::LocalGitRepo.new(remote, config.REPOSTORE_PATH)
    end

    def local
      exists_locally? ? @local : raise(Errors::NoTranslateTextFound)
    end

    def delete
      @local.delete
    end

    def exists_locally?
      @local.exists?
    end

    def translate_locally
      # raise Errors::TooLargeToClone if @project.too_large?
      # raise Errors::CannotOverwriteLocalGitRepo if exists_locally?

      @local.clone_remote { |line| yield line if block_given? }
    end
  end
end
