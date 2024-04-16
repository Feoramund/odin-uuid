# odin-uuid

This package implements Universally Unique Identifiers according to the
standard outlined in [RFC 4122](https://www.rfc-editor.org/rfc/rfc4122.html).

Generation of versions 1 and 2 (the MAC address-based versions) are not yet
implemented.

## Example

```odin
// Generation
id4 := uuid.generate_v4()
id5 := uuid.generate_v5(uuid.Namespace_URL, "odin-lang.org")

// Conversion
id4_str := uuid.to_string(id4)
fmt.println(id4_str)

// Reading
id_from_str, error := uuid.read("00000000-0000-4000-8000-000000000000")

// Writing
stdout := os.stream_from_handle(os.stdout)
uuid.write(stdout, id5)
```
