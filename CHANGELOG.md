0.5.0
Introduce ability to specify type on the resource object
Speed up serialization by caching type if it's not specified

0.4.5
Speed up serialization by removing superfluous call

0.4.4
Fixed an issue with complex includes

0.4.3
Removed the constraint on activesupport 3. Should be >= 3 not ~> 3

0.4.2
Fixed an issue where serializing a collection with `include` options could result in duplicate
data returned in the `included` key

0.4.1
Some major refactoring but no backwards compatibility breaking functionality

0.4.0
Add support for nested includes and link enabling/disabling

0.3.0
Added `cardinality` instance method to `ToManyRelationship` and `ToOneRelationship`

0.2.2
Fix issues with `id_field` returning a string and not supporting method overriding

0.2.1
Fix issues with `_id_field` on subclasses of class whose superclass is Resource

0.2.0
Added the ability to subclass from a class whose superclass is Resource

0.1.1
Fix issues related to empty or nil objects

0.1.0
Added the ability to set a `resource_class` on relationships
Made resource discovery able to handle a string or a class object

0.0.3
Performance tuning and documentation

0.0.2
Changed 'class_name' to 'resource_class' for consistency
