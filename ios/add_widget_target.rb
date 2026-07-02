#!/usr/bin/env ruby
# frozen_string_literal: true
#
# add_widget_target.rb
# Adds a WidgetKit extension target (SalaryFlowWidget) to the Xcode project.
# Idempotent – re-running is safe; it exits 0 if the target already exists.
#
# Usage (run from repo root OR from ios/ directory):
#   ruby ios/add_widget_target.rb
#
# Requirements:
#   gem install xcodeproj

require 'xcodeproj'

WIDGET_NAME       = 'SalaryFlowWidget'
WIDGET_BUNDLE_ID  = 'com.example.salaryFlow.widget'
DEPLOY_TARGET     = '16.0'
APP_GROUP         = 'group.com.example.salaryFlow'
WIDGET_DIR        = WIDGET_NAME  # relative to ios/

# Resolve the .xcodeproj path regardless of CWD
script_dir   = File.expand_path(__dir__)
project_path = File.join(script_dir, 'Runner.xcodeproj')

unless File.exist?(project_path)
  abort "ERROR: could not find Runner.xcodeproj at #{project_path}"
end

project = Xcodeproj::Project.open(project_path)

# ── Idempotency check ──────────────────────────────────────────────────────────
if project.targets.any? { |t| t.name == WIDGET_NAME }
  puts "✓ '#{WIDGET_NAME}' target already present — nothing to do."
  exit 0
end

puts "➤ Adding WidgetKit extension target: #{WIDGET_NAME}"

# ── Create the extension target ───────────────────────────────────────────────
widget_target = project.new_target(
  :app_extension,
  WIDGET_NAME,
  :ios,
  DEPLOY_TARGET
)
# Override to widgetkit-extension product type
widget_target.product_type = 'com.apple.product-type.widgetkit-extension'

# ── Build settings ────────────────────────────────────────────────────────────
widget_target.build_configurations.each do |cfg|
  s = cfg.build_settings
  s['INFOPLIST_FILE']                   = "#{WIDGET_DIR}/Info.plist"
  s['PRODUCT_BUNDLE_IDENTIFIER']        = WIDGET_BUNDLE_ID
  s['SWIFT_VERSION']                    = '5.0'
  s['TARGETED_DEVICE_FAMILY']           = '1,2'
  s['IPHONEOS_DEPLOYMENT_TARGET']       = DEPLOY_TARGET
  s['SKIP_INSTALL']                     = 'YES'
  s['BUILD_LIBRARY_FOR_DISTRIBUTION']   = 'NO'
  s['CODE_SIGN_ENTITLEMENTS']           = "#{WIDGET_DIR}/#{WIDGET_NAME}.entitlements"
  # CI signing – overridden by signing profile in production builds
  s['CODE_SIGNING_ALLOWED']             = 'NO'
  s['CODE_SIGNING_REQUIRED']            = 'NO'
  s['CODE_SIGN_IDENTITY']               = ''
  s['GENERATE_INFOPLIST_FILE']          = 'NO'
end

# ── File references (source group) ───────────────────────────────────────────
# Re-use existing group if already present (shouldn't be, but be safe)
widget_group = project.main_group.groups.find { |g| g.display_name == WIDGET_NAME }
widget_group ||= project.main_group.new_group(WIDGET_NAME, WIDGET_DIR)

swift_ref = widget_group.new_file("#{WIDGET_NAME}.swift")
widget_target.source_build_phase.add_file_reference(swift_ref)

# Info.plist & entitlements are referenced but not compiled
widget_group.new_file('Info.plist')
widget_group.new_file("#{WIDGET_NAME}.entitlements")

# ── Wire up to the Runner target ─────────────────────────────────────────────
runner_target = project.targets.find { |t| t.name == 'Runner' }
unless runner_target
  abort 'ERROR: could not find the Runner target in the project.'
end

# Add entitlements to Runner's build settings (for App Groups)
runner_target.build_configurations.each do |cfg|
  cfg.build_settings['CODE_SIGN_ENTITLEMENTS'] ||= 'Runner/Runner.entitlements'
end

# Target dependency
runner_target.add_dependency(widget_target)

# Embed App Extensions build phase
embed_phase = runner_target.copy_files_build_phases.find do |phase|
  phase.name == 'Embed Foundation Extensions'
end

unless embed_phase
  embed_phase = runner_target.new_copy_files_build_phase('Embed Foundation Extensions')
  embed_phase.dst_subfolder_spec = '13' # PlugIns
end

build_file = embed_phase.add_file_reference(widget_target.product_reference)
build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }


# ── Save ─────────────────────────────────────────────────────────────────────
project.save
puts "✅ '#{WIDGET_NAME}' extension target added successfully!"
puts "   Bundle ID : #{WIDGET_BUNDLE_ID}"
puts "   App Group : #{APP_GROUP}"
puts ""
puts "⚠️  Remember to enable the 'App Groups' capability in Xcode for BOTH"
puts "   the Runner and #{WIDGET_NAME} targets and add: #{APP_GROUP}"
