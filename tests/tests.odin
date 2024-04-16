package tests

import "core:testing"
import uuid "../src"

@(test)
test_version_and_variant :: proc(t: ^testing.T) {
    v3 := uuid.generate_v3(uuid.Namespace_DNS, "")
    v4 := uuid.generate_v4()
    v5 := uuid.generate_v5(uuid.Namespace_DNS, "")

    testing.expect_value(t, uuid.version(v3), 3)
    testing.expect_value(t, uuid.variant(v3), uuid.Variant_Type.RFC_4122)
    testing.expect_value(t, uuid.version(v4), 4)
    testing.expect_value(t, uuid.variant(v4), uuid.Variant_Type.RFC_4122)
    testing.expect_value(t, uuid.version(v5), 5)
    testing.expect_value(t, uuid.variant(v5), uuid.Variant_Type.RFC_4122)
}

@(test)
test_namespaced_uuids :: proc(t: ^testing.T) {
    Test_Name :: "0123456789ABCDEF0123456789ABCDEF"

    Expected_Result :: struct {
        namespace: uuid.UUID,
        v3, v5: string,
    }

    Expected_Results := [?]Expected_Result {
        { uuid.Namespace_DNS, "80147f37-36db-3b82-b78f-810c3c6504ba","18394c41-13a2-593f-abf2-a63e163c2860"},
        { uuid.Namespace_URL, "8136789b-8e16-3fbd-800b-1587e2f22521", "07337422-eb77-5fd3-99af-c7f59e641e13" },
        { uuid.Namespace_OID, "adbb95bc-ea50-3226-9a75-20c34a6030f8", "24db9b0f-70b8-53c4-a301-f695ce17276d" },
        { uuid.Namespace_X500, "a8965ad1-0e54-3d65-b933-8b7cca8e8313", "3012bf2d-fac4-5187-9825-493e6636b936"},
    }

    for exp in Expected_Results {
        v3 := uuid.generate_v3(exp.namespace, Test_Name)
        v5 := uuid.generate_v5(exp.namespace, Test_Name)

        v3_str := uuid.to_string(v3)
        defer delete(v3_str)

        v5_str := uuid.to_string(v5)
        defer delete(v5_str)

        testing.expect_value(t, v3_str, exp.v3)
        testing.expect_value(t, v5_str, exp.v5)
    }
}

@(test)
test_writing :: proc(t: ^testing.T) {
    id: uuid.UUID

    for &b, i in id.bytes {
        b = u8(i)
    }

    s := uuid.to_string(id)
    defer delete(s)

    testing.expect_value(t, s, "00010203-0405-0607-0809-0a0b0c0d0e0f")
}

@(test)
test_reading :: proc(t: ^testing.T) {
    id, err := uuid.read("00010203-0405-0607-0809-0a0b0c0d0e0f")
    testing.expect_value(t, err, nil)

    for b, i in id.bytes {
        testing.expect_value(t, b, u8(i))
    }
}

@(test)
test_reading_errors :: proc(t: ^testing.T) {
    {
        Bad_String :: "|.......@....@....@....@............"
        _, err := uuid.read(Bad_String)
        testing.expect_value(t, err, uuid.Read_Error.Invalid_Separator)
    }

    {
        Bad_String :: "|.......-....-....-....-............"
        _, err := uuid.read(Bad_String)
        testing.expect_value(t, err, uuid.Read_Error.Invalid_Hexadecimal)
    }

    {
        Bad_String :: ".......-....-....-....-............"
        _, err := uuid.read(Bad_String)
        testing.expect_value(t, err, uuid.Read_Error.Invalid_Length)
    }

    {
        Bad_String :: "|.......-....-....-....-............|"
        _, err := uuid.read(Bad_String)
        testing.expect_value(t, err, uuid.Read_Error.Invalid_Length)
    }

    {
        Bad_String :: "00000000-0000-0000-0000-0000000000001"
        _, err := uuid.read(Bad_String)
        testing.expect_value(t, err, uuid.Read_Error.Invalid_Length)
    }

    {
        Bad_String :: "00000000000000000000000000000000"
        _, err := uuid.read(Bad_String)
        testing.expect_value(t, err, uuid.Read_Error.Invalid_Length)
    }

    {
        Ok_String :: "00000000-0000-0000-0000-000000000000"
        _, err := uuid.read(Ok_String)
        testing.expect_value(t, err, uuid.Read_Error.Ok)
    }
}
