#![allow(
    non_camel_case_types,
    unused,
    clippy::redundant_closure,
    clippy::useless_conversion,
    non_snake_case
)]
// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`.

use crate::api::*;
use flutter_rust_bridge::*;

// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_init_logger(port_: i64) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "init_logger",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || move |task_callback| init_logger(),
    )
}

#[no_mangle]
pub extern "C" fn wire_connect_p2p(port_: i64, url: *mut wire_uint_8_list) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "connect_p2p",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_url = url.wire2api();
            move |task_callback| connect_p2p(api_url)
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_send_identity_challenge_event(port_: i64) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "send_identity_challenge_event",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || move |task_callback| send_identity_challenge_event(),
    )
}

#[no_mangle]
pub extern "C" fn wire_get_event(port_: i64) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "get_event",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || move |task_callback| get_event(),
    )
}

#[no_mangle]
pub extern "C" fn wire_verify_peer_did_document(
    port_: i64,
    provider_pk: *mut wire_uint_8_list,
    signature: *mut wire_uint_8_list,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "verify_peer_did_document",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_provider_pk = provider_pk.wire2api();
            let api_signature = signature.wire2api();
            move |task_callback| verify_peer_did_document(api_provider_pk, api_signature)
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_verify_peer_identity(
    port_: i64,
    provider_pk: *mut wire_uint_8_list,
    plain_data: *mut wire_uint_8_list,
    signature: *mut wire_uint_8_list,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "verify_peer_identity",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_provider_pk = provider_pk.wire2api();
            let api_plain_data = plain_data.wire2api();
            let api_signature = signature.wire2api();
            move |task_callback| {
                verify_peer_identity(api_provider_pk, api_plain_data, api_signature)
            }
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_fetch_did_document(
    port_: i64,
    ws_url: *mut wire_uint_8_list,
    public_key: *mut wire_uint_8_list,
    storage_name: *mut wire_uint_8_list,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "fetch_did_document",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_ws_url = ws_url.wire2api();
            let api_public_key = public_key.wire2api();
            let api_storage_name = storage_name.wire2api();
            move |task_callback| fetch_did_document(api_ws_url, api_public_key, api_storage_name)
        },
    )
}

// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
}

// Section: wire enums

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_uint_8_list(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: impl Wire2Api

pub trait Wire2Api<T> {
    fn wire2api(self) -> T;
}

impl<T, S> Wire2Api<Option<T>> for *mut S
where
    *mut S: Wire2Api<T>,
{
    fn wire2api(self) -> Option<T> {
        if self.is_null() {
            None
        } else {
            Some(self.wire2api())
        }
    }
}

impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}

impl Wire2Api<u8> for u8 {
    fn wire2api(self) -> u8 {
        self
    }
}

impl Wire2Api<Vec<u8>> for *mut wire_uint_8_list {
    fn wire2api(self) -> Vec<u8> {
        unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        }
    }
}

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}

// Section: impl IntoDart

// Section: executor
support::lazy_static! {
    pub static ref FLUTTER_RUST_BRIDGE_HANDLER: support::DefaultHandler = Default::default();
}

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturnStruct(val: support::WireSyncReturnStruct) {
    unsafe {
        let _ = support::vec_from_leak_ptr(val.ptr, val.len);
    }
}