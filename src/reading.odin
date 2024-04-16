package uuid

Read_Error :: enum {
	Ok,
	Invalid_Length,
	Invalid_Hexadecimal,
	Invalid_Separator,
}

// Convert a string to a UUID.
//
// This procedure accepts the 8-4-4-4-12 format.
read :: proc "contextless" (s: string) -> (result: UUID, error: Read_Error) #no_bounds_check {
	Expected_Length :: 8 + 4 + 4 + 4 + 12 + 4

	// Only exact-length strings are acceptable.
	if len(s) != Expected_Length {
		return {}, .Invalid_Length
	}

	// Check ahead to see if the separators are in the right places.
	if s[8] != '-' || s[13] != '-' || s[18] != '-' || s[23] != '-' {
		return {}, .Invalid_Separator
	}

	read_nibble :: proc "contextless" (nibble: u8) -> u8 {
		switch nibble {
		case '0' ..= '9':
			return nibble - '0'
		case 'A' ..= 'F':
			return nibble - 'A' + 10
		case 'a' ..= 'f':
			return nibble - 'a' + 10
		case:
			// Return an error value.
			return 0xFF
		}
	}

	index := 0
	octet_index := 0

	Chunks :: [5]int{8, 4, 4, 4, 12}

	for chunk in Chunks {
		for i := index; i < index + chunk; i += 2 {
			high := read_nibble(s[i])
			low := read_nibble(s[i + 1])

			if high | low > 0xF {
				return {}, .Invalid_Hexadecimal
			}

			result.bytes[octet_index] = low | high << 4
			octet_index += 1
		}

		index += chunk + 1
	}

	return
}

// Get the version of a UUID.
version :: proc "contextless" (id: UUID) -> int {
	return cast(int)(id.bytes[VERSION_BYTE_INDEX] & 0xF0 >> 4)
}

// Get the variant of a UUID.
variant :: proc "contextless" (id: UUID) -> Variant_Type {
	switch {
	case id.bytes[VARIANT_BYTE_INDEX] & 0x80 == 0:
		return .Reserved_Apollo_NCS
	case id.bytes[VARIANT_BYTE_INDEX] & 0xC0 == 0x80:
		return .RFC_4122
	case id.bytes[VARIANT_BYTE_INDEX] & 0xE0 == 0xC0:
		return .Reserved_Microsoft_COM
	case id.bytes[VARIANT_BYTE_INDEX] & 0xF0 == 0xE0:
		return .Reserved_Future
	case:
		return .Unknown
	}
}
