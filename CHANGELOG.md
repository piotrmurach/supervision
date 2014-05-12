0.2.0 (May 12, 2014)

* Add InvalidParameterError, DuplicateEntryError types
* Add on_success & on_failure callbacks
* Change configuration to have more expressive setters
* Add shutdown to circuit system
* Add ability for dynamic calls on Supervision module
* Add ability to call supervised methods directly on object
  when Supervision is included as a module
* Add ability to force reset circuit to closed state
* Add tests to ensure reset scheduler works properly
* Add ability to query configuration options on supervision instance
