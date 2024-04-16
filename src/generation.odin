package uuid

import "core:crypto/legacy/md5"
import "core:crypto/legacy/sha1"
import "core:math/rand"
import "core:mem"

generate_v3_bytes :: proc(
	namespace: UUID,
	name: []byte,
	r: ^rand.Rand = nil,
) -> (
	result: UUID,
) {
	namespace := namespace

	ctx: md5.Context
	md5.init(&ctx)
	md5.update(&ctx, namespace.bytes[:])
	md5.update(&ctx, name)
	md5.final(&ctx, result.bytes[:])

	result.bytes[VERSION_BYTE_INDEX] &= 0x0F
	result.bytes[VERSION_BYTE_INDEX] |= 0x30

	result.bytes[VARIANT_BYTE_INDEX] &= 0x3F
	result.bytes[VARIANT_BYTE_INDEX] |= 0x80

	return
}

generate_v3_string :: proc(
	namespace: UUID,
	name: string,
	r: ^rand.Rand = nil,
) -> (
	result: UUID,
) {
	return generate_v3_bytes(namespace, transmute([]byte)name, r)
}

// Generate a version 3 UUID.
//
// This UUID is generated from a name within a namespace.
// MD5 is used to hash the name with the namespace to produce the UUID.
generate_v3 :: proc {
	generate_v3_bytes,
	generate_v3_string,
}

// Generate a version 4 UUID.
//
// This UUID will be pseudorandom, save for 6 pre-determined version and
// variant bits.
generate_v4 :: proc(r: ^rand.Rand = nil) -> (result: UUID) {
	result.integer = transmute(u128be)rand.uint128(r)

	result.bytes[VERSION_BYTE_INDEX] &= 0x0F
	result.bytes[VERSION_BYTE_INDEX] |= 0x40

	result.bytes[VARIANT_BYTE_INDEX] &= 0x3F
	result.bytes[VARIANT_BYTE_INDEX] |= 0x80

	return
}

generate_v5_bytes :: proc(
	namespace: UUID,
	name: []byte,
	r: ^rand.Rand = nil,
) -> (
	result: UUID,
) {
	namespace := namespace
	digest: [sha1.DIGEST_SIZE]byte

	ctx: sha1.Context
	sha1.init(&ctx)
	sha1.update(&ctx, namespace.bytes[:])
	sha1.update(&ctx, name)
	sha1.final(&ctx, digest[:])

	mem.copy_non_overlapping(&result.bytes, &digest, 16)

	result.bytes[VERSION_BYTE_INDEX] &= 0x0F
	result.bytes[VERSION_BYTE_INDEX] |= 0x50

	result.bytes[VARIANT_BYTE_INDEX] &= 0x3F
	result.bytes[VARIANT_BYTE_INDEX] |= 0x80

	return
}

generate_v5_string :: proc(
	namespace: UUID,
	name: string,
	r: ^rand.Rand = nil,
) -> (
	result: UUID,
) {
	return generate_v5_bytes(namespace, transmute([]byte)name, r)
}

// Generate a version 5 UUID.
//
// This UUID is generated from a name within a namespace.
// SHA1 is used to hash the name with the namespace to produce the UUID.
generate_v5 :: proc {
	generate_v5_bytes,
	generate_v5_string,
}
