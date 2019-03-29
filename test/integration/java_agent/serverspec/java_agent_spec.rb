# frozen_string_literal: true

require 'serverspec'

# Required by serverspec
set :backend, :exec

describe file('/tmp/environment') do
  its(:content) { should match(%r{^export JAVA_OPTS="\$JAVA_OPTS -agentpath:/opt/dynatrace/agent/lib64/libdtagent.so=name=java-agent,collector=localhost:9998"$}) }
end
