module Danger
  # Force locking down of version numbers in package.json
  #
  # Shrinkwrap isn't the solution you want it to be, and none of the other tools
  # quite do what you want. So you'll get fed up and force manual management of
  # your dependencies (after all, `npm outdated` is fairly easy to deal with.)
  #
  # This plugin will warn you if you're commiting anything that looks like:
  #
  #  - "^1.0.0"
  #  - "~1.0.0"
  #  - "<=1.0.0"
  #  - "<1.0.0"
  #  - ">=1.0.0"
  #  - ">1.0.0"
  #  - "1.0.x"
  #  - "*"
  #  - ""
  #
  # So you can still specify a git hash, a tag, or a URL (and so on), and, most
  # importantly, you can specify a version number.
  #
  # @example Basic operation, throwing warnings in specified package.json(s)
  #
  #          package_json_lockdown.verify('package.json')
  #          package_json_lockdown.verify('path/to/sub/package.json')
  #
  # @example Blacklisting specific dependencies nodes
  #
  #          # Will only check the `dependencies` node, but allow
  #          #  `devDependencies` to contain non-specific versions
  #          package_json_lockdown.dependency_keys = ['dependencies']
  #          package_json_lockdown.verify('package.json')
  #
  # @example Returning values to handle manually
  #
  #          problems = package_json_lockdown.inspect('package.json')
  #          puts(problems)
  #
  # @tags npm, package.json, node, nodejs
  #
  class DangerPackageJsonLockdown < Plugin
    # Allows you to specify dependency nodes to check. By default it will check
    # all nodes known to contain dependencies.
    #
    # @return   [Array<String>]
    attr_accessor :dependency_keys

    def dependency_keys
      @dependency_keys || %w(
        dependencies
        devDependencies
        peerDependencies
        bundleDependencies
        bundledDependencies
        optionalDependencies
      )
    end

    # Verifies the supplied `package.json` file
    # @param    [string] package_json
    #           Path to `package.json`, relative to current directory
    # @return   [void]
    def verify(package_json)
      inspect(package_json).each do |suspicious|
        warn(
          "`#{suspicious[:package]}` doesn't specify fixed version number",
          file: package_json,
          line: suspicious[:line]
        )
      end
    end

    # Inspects the supplied `package.json` file and returns problems
    # @param    [string] package_json
    #           Path to `package.json`, relative to current directory
    # @return   [Array<{Symbol => String}>]
    #            - `:package`: the offending package name
    #            - `:version`: the version as written in `package.json`
    #            - `:line`: (probably) the line number.
    def inspect(package_json)
      json = JSON.parse(File.read(package_json))

      suspicious_packages = []

      dependency_keys.each do |dependency_key|
        next unless json.key?(dependency_key)

        results = find_something_suspicious(json[dependency_key], package_json)
        suspicious_packages.push(*results)
      end

      suspicious_packages
    end

    private

    def find_something_suspicious(dependency_node, package_json)
      suspicious_packages = []

      dependency_node.each do |package, version|
        obj = {
          package: package,
          version: version,
          line: line_number_of_package(package, package_json)
        }
        suspicious_packages.push(obj) if suspicious?(version)
      end

      suspicious_packages
    end

    def suspicious?(version)
      version =~ /^[\^<>\*~]/ ||
        version =~ /\.x/ ||
        version == ''
    end

    def line_number_of_package(package, package_json)
      `grep -n '\"#{package}\":' #{package_json} | cut -f1 -d:`.strip
    end
  end
end
