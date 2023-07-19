use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_init_logger(port_: i64) {
    wire_init_logger_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_connect_p2p(port_: i64, url: *mut wire_uint_8_list) {
    wire_connect_p2p_impl(port_, url)
}

#[no_mangle]
pub extern "C" fn wire_disconnect_p2p(port_: i64, peer_id: *mut wire_uint_8_list) {
    wire_disconnect_p2p_impl(port_, peer_id)
}

#[no_mangle]
pub extern "C" fn wire_send_identity_challenge_event(port_: i64) {
    wire_send_identity_challenge_event_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_send_stop_charge_event(port_: i64) {
    wire_send_stop_charge_event_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_send_service_requested_event(
    port_: i64,
    provider: *mut wire_uint_8_list,
    consumer: *mut wire_uint_8_list,
    token_deposited: *mut wire_uint_8_list,
) {
    wire_send_service_requested_event_impl(port_, provider, consumer, token_deposited)
}

#[no_mangle]
pub extern "C" fn wire_get_account_balance(
    port_: i64,
    ws_url: *mut wire_uint_8_list,
    token_decimals: *mut wire_uint_8_list,
    seed: *mut wire_uint_8_list,
) {
    wire_get_account_balance_impl(port_, ws_url, token_decimals, seed)
}

#[no_mangle]
pub extern "C" fn wire_generate_account(
    port_: i64,
    ws_url: *mut wire_uint_8_list,
    secret_phrase: *mut wire_uint_8_list,
) {
    wire_generate_account_impl(port_, ws_url, secret_phrase)
}

#[no_mangle]
pub extern "C" fn wire_create_multisig_address(
    port_: i64,
    signatories: *mut wire_StringList,
    threshold: u16,
) {
    wire_create_multisig_address_impl(port_, signatories, threshold)
}

#[no_mangle]
pub extern "C" fn wire_approve_multisig(
    port_: i64,
    ws_url: *mut wire_uint_8_list,
    threshold: u16,
    other_signatories: *mut wire_StringList,
    timepoint_height: u32,
    timepoint_index: u32,
    call_hash: *mut wire_uint_8_list,
    seed: *mut wire_uint_8_list,
) {
    wire_approve_multisig_impl(
        port_,
        ws_url,
        threshold,
        other_signatories,
        timepoint_height,
        timepoint_index,
        call_hash,
        seed,
    )
}

#[no_mangle]
pub extern "C" fn wire_transfer_fund(
    port_: i64,
    ws_url: *mut wire_uint_8_list,
    address: *mut wire_uint_8_list,
    amount: *mut wire_uint_8_list,
    seed: *mut wire_uint_8_list,
) {
    wire_transfer_fund_impl(port_, ws_url, address, amount, seed)
}

#[no_mangle]
pub extern "C" fn wire_get_event(port_: i64) {
    wire_get_event_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_verify_peer_did_document(
    port_: i64,
    provider_pk: *mut wire_uint_8_list,
    signature: *mut wire_uint_8_list,
) {
    wire_verify_peer_did_document_impl(port_, provider_pk, signature)
}

#[no_mangle]
pub extern "C" fn wire_verify_peer_identity(
    port_: i64,
    provider_pk: *mut wire_uint_8_list,
    plain_data: *mut wire_uint_8_list,
    signature: *mut wire_uint_8_list,
) {
    wire_verify_peer_identity_impl(port_, provider_pk, plain_data, signature)
}

#[no_mangle]
pub extern "C" fn wire_fetch_did_document(
    port_: i64,
    ws_url: *mut wire_uint_8_list,
    public_key: *mut wire_uint_8_list,
    storage_name: *mut wire_uint_8_list,
) {
    wire_fetch_did_document_impl(port_, ws_url, public_key, storage_name)
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_StringList_0(len: i32) -> *mut wire_StringList {
    let wrap = wire_StringList {
        ptr: support::new_leak_vec_ptr(<*mut wire_uint_8_list>::new_with_null_ptr(), len),
        len,
    };
    support::new_leak_box_ptr(wrap)
}

#[no_mangle]
pub extern "C" fn new_uint_8_list_0(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: related functions

// Section: impl Wire2Api

impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}
impl Wire2Api<Vec<String>> for *mut wire_StringList {
    fn wire2api(self) -> Vec<String> {
        let vec = unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        };
        vec.into_iter().map(Wire2Api::wire2api).collect()
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
// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_StringList {
    ptr: *mut *mut wire_uint_8_list,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
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

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturn(ptr: support::WireSyncReturn) {
    unsafe {
        let _ = support::box_from_leak_ptr(ptr);
    };
}
