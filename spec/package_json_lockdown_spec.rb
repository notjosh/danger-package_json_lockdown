require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerPackageJsonLockdown, use: :ci_helper do
    it 'should be a plugin' do
      expect(Danger::DangerPackageJsonLockdown.new(nil)).to be_a Danger::Plugin
    end

    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @package_json_lockdown = @dangerfile.package_json_lockdown
      end

      it 'Accepts valid package.json' do
        @package_json_lockdown.verify('spec/fixtures/valid.json')
        expect(@dangerfile.status_report[:warnings]).to eq([])
      end

      it 'Warns on package.json with non-specific versions' do
        @package_json_lockdown.verify('spec/fixtures/invalid.json')

        warnings = [
          '`@kadira/react-native-storybook` doesn\'t specify fixed version ' \
            'number',
          '`babel-jest` doesn\'t specify fixed version number',
          '`babel-plugin-flow-react-proptypes` doesn\'t specify fixed ' \
            'version number',
          '`babel-preset-react-native` doesn\'t specify fixed version number',
          '`eslint-config-airbnb-flow` doesn\'t specify fixed version number',
          '`eslint-plugin-import` doesn\'t specify fixed version number',
          '`eslint-plugin-jsx-a11y` doesn\'t specify fixed version number'
        ]
        expect(@dangerfile.status_report[:warnings]).to eq(warnings)
      end

      it 'Allows specifying dependency JSON keys' do
        @package_json_lockdown.dependency_keys = ['dependencies']
        @package_json_lockdown.verify('spec/fixtures/invalid.json')

        expect(@dangerfile.status_report[:warnings]).to eq([])
      end

      it 'Returns suspicious packages without warning if inspecting' do
        suspicious = @package_json_lockdown.inspect(
          'spec/fixtures/invalid.json'
        )

        expected = [
          {
            package: '@kadira/react-native-storybook',
            version: '^2.1.3',
            line: '10'
          },
          {
            package: 'babel-jest',
            version: '>=15.0.0',
            line: '11'
          },
          {
            package: 'babel-plugin-flow-react-proptypes',
            version: '<0.12.2',
            line: '12'
          },
          {
            package: 'babel-preset-react-native',
            version: '~1.9.0',
            line: '13'
          },
          {
            package: 'eslint-config-airbnb-flow',
            version: '1.0.x',
            line: '14'
          },
          {
            package: 'eslint-plugin-import',
            version: '',
            line: '15'
          },
          {
            package: 'eslint-plugin-jsx-a11y',
            version: '*',
            line: '16'
          }
        ]
        expect(suspicious).to eq(expected)
      end
    end
  end
end
