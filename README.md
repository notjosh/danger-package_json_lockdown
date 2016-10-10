

### package_json_lockdown

Force locking down of version numbers in package.json

Shrinkwrap isn't the solution you want it to be, and none of the other tools
quite do what you want. So you'll get fed up and force manual management of
your dependencies (after all, `npm outdated` is fairly easy to deal with.)

This plugin will warn you if you're commiting anything that looks like:

 - "^1.0.0"
 - "~1.0.0"
 - "<=1.0.0"
 - "<1.0.0"
 - ">=1.0.0"
 - ">1.0.0"
 - "1.0.x"
 - "*"
 - ""

So you can still specify a git hash, a tag, or a URL (and so on), and, most
importantly, you can specify a version number.

<blockquote>Basic operation, throwing warnings in specified package.json(s)
  <pre>
package_json_lockdown.verify('package.json')
package_json_lockdown.verify('path/to/sub/package.json')</pre>
</blockquote>

<blockquote>Blacklisting specific dependencies nodes
  <pre>
# Will only check the `dependencies` node, but allow
#  `devDependencies` to contain non-specific versions
package_json_lockdown.dependency_keys = ['dependencies']
package_json_lockdown.verify('package.json')</pre>
</blockquote>

<blockquote>Returning values to handle manually
  <pre>
problems = package_json_lockdown.inspect('package.json')
puts(problems)</pre>
</blockquote>



#### Attributes

`dependency_keys` - Allows you to specify dependency nodes to check. By default it will check
all nodes known to contain dependencies.




#### Methods

`verify` - Verifies the supplied `package.json` file

`inspect` - Inspects the supplied `package.json` file and returns problems




