# frozen_string_literal: true

module TranslateText
  # Infrastructure to translate while yielding progress
  module TranslateTextMonitor
    SHOW_PROGRESS = {
      'STARTED'   => 15,
      'Calling'   => 30,
      'remote'    => 70,
      'Receiving' => 85,
      'Resolving' => 95,
      'Checking'  => 100,
      'FINISHED'  => 100
    }.freeze

    def self.starting_percent
      SHOW_PROGRESS['STARTED'].to_s
    end

    def self.finished_percent
      SHOW_PROGRESS['FINISHED'].to_s
    end

    def self.progress(line)
      SHOW_PROGRESS[first_word_of(line)].to_s
    end

    def self.percent(stage)
      SHOW_PROGRESS[stage].to_s
    end

    def self.first_word_of(line)
      line.match(/^[A-Za-z]+/).to_s
    end
  end
end
