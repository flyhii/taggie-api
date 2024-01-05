# frozen_string_literal: true

require 'faye'
require_relative 'require_app'
require_app

use Faye::RackAdapter, mount: '/faye', timeout: 10
run FlyHii::App.freeze.app
