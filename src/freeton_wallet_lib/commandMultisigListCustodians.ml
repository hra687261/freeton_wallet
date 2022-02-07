(**************************************************************************)
(*                                                                        *)
(*  Copyright (c) 2021 OCamlPro SAS                                       *)
(*                                                                        *)
(*  All rights reserved.                                                  *)
(*  This file is distributed under the terms of the GNU Lesser General    *)
(*  Public License version 2.1, with the special exception on linking     *)
(*  described in the LICENSE.md file in the root directory.               *)
(*                                                                        *)
(*                                                                        *)
(**************************************************************************)

open EzCompat (* for StringMap *)
open Ezcmd.V2
open EZCMD.TYPES

let get_custodians account =
  let config = Config.config () in
  let ctxt = Multisig.get_context config account in
  let custodians = Multisig.get_custodians ctxt in
  let name_by_pubkey = Multisig.name_by_pubkey ctxt.net in
  let name_by_pubkey s =
    match StringMap.find s name_by_pubkey with
    | exception Not_found -> s
    | name -> Printf.sprintf "%s (%s)" name s
  in

  Printf.printf "     Custodians: %d\n%!"
    ( List.length custodians);
  List.iter (fun c ->
      Printf.printf "       %s: %s\n%!"
        c.Types.MULTISIG.index (name_by_pubkey c.pubkey)
    ) custodians;
  ()

let action account =

  let account = match account with
    | None ->
        Error.raise "You must provide the account"
    | Some account -> account
  in
  get_custodians account ;
  ()

let cmd =
  let account = ref None in
  EZCMD.sub
    "multisig list custodians"
    (fun () ->
       action !account
    )
    ~args:
      [
        [], Arg.Anon (0, fun s -> account := Some s),
        EZCMD.info ~docv:"ACCOUNT" "The multisig account";
      ]
    ~doc: "List owners/custodians of a multisig wallet"
    ~man:[
      `S "DESCRIPTION";
      `P "This command can be used to display the pubkeys of the owners/custodians of a multisig wallet";
      `P "To get the list of signers:";
      `Pre {|# ft multisig list custodians MY-ACCOUNT"|};
    ]
