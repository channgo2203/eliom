(* Ocsigen
 * http://www.ocsigen.org
 * Copyright (C) 2010
 * Vincent Balat
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, with linking exception;
 * either version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)

{client{

let _ = Eliom_client.init ()

(* The following lines are for Eliom_bus, Eliom_comet and Eliom_react
   to be linked. *)
let _force_link =
  Eliom_react.force_link,
  Eliom_comet.force_link,
  Eliom_bus.force_link
}}

{client{

let default_reload () =
  Dom_html.window##location##reload();
  Lwt.return ()

let reload () =
  match !Eliom_client.reload_function with
  | Some f ->
    f () ()
  | None ->
    default_reload ()

let reload_without_na_params () () =
  let uri = !Eliom_client.current_uri in
  try_lwt
    let path, args =
      match Url.url_of_string uri with
      | Some (Url.Http url | Url.Https url) ->
        url.Url.hu_path, url.Url.hu_arguments
      | _ ->
        match
          try
            Some (String.index uri '?')
          with Not_found ->
            None
        with
        | Some n ->
          Eliom_lib.Url.split_path String.(sub uri 0 n),
          Url.decode_arguments String.(sub uri (n + 1) (length uri - n - 1))
        | None ->
          Eliom_lib.Url.split_path uri, []
    in
    Eliom_client.change_page_unknown path
      (Eliom_common.remove_na_prefix_params args)
      []
  with _ ->
    reload ()

let switch_to_https () =
  let info = Eliom_process.get_info () in
  Eliom_process.set_info {info with Eliom_common.cpi_ssl = true }

}}

{shared{

(* Client side implementation of reload actions *)
let _ =
  Eliom_service.internal_set_client_fun
    ~service:Eliom_service.reload_action
    {{ reload_without_na_params }};
  Eliom_service.internal_set_client_fun
    ~service:Eliom_service.reload_action_https
    {{
      fun () () ->
        switch_to_https ();
        reload_without_na_params () ()
    }};
  Eliom_service.internal_set_client_fun
    ~service:Eliom_service.reload_action_hidden
    {{  fun () () -> reload () }};
  Eliom_service.internal_set_client_fun
    ~service:Eliom_service.reload_action_https_hidden
    {{  fun () () -> switch_to_https (); reload () }}

 }}
