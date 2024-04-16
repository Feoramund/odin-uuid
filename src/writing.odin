package uuid

import "core:io"
import "core:strconv"
import "core:strings"

// Write a UUID in the 8-4-4-4-12 format.
//
// Example: `00000000-0000-4000-8000-000000000000`
write :: proc(w: io.Writer, id: UUID) {
	write_octet :: proc(w: io.Writer, octet: u8) {
		high_nibble := octet >> 4
		low_nibble := octet & 0xF

		io.write_byte(w, strconv.digits[high_nibble])
		io.write_byte(w, strconv.digits[low_nibble])
	}

	for index in 0 ..< 4 {write_octet(w, id.bytes[index])}
	io.write_byte(w, '-')
	for index in 4 ..< 6 {write_octet(w, id.bytes[index])}
	io.write_byte(w, '-')
	for index in 6 ..< 8 {write_octet(w, id.bytes[index])}
	io.write_byte(w, '-')
	for index in 8 ..< 10 {write_octet(w, id.bytes[index])}
	io.write_byte(w, '-')
	for index in 10 ..< 16 {write_octet(w, id.bytes[index])}
}

// Convert a UUID to a string in the 8-4-4-4-12 format.
//
// Example: `00000000-0000-4000-8000-000000000000`
//
// Allocates using the provided allocator.
to_string :: proc(id: UUID, allocator := context.allocator) -> string {
	builder := strings.builder_make(allocator)
	write(strings.to_writer(&builder), id)
	return strings.to_string(builder)
}
