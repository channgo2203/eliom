(* Ocsigen
 * http://www.ocsigen.org
 * Module eliomsessiongroups.ml
 * Copyright (C) 2007 Vincent Balat
 * Laboratoire PPS - CNRS Université Paris Diderot
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

val make_full_group_name : 
  Ocsigen_extensions.request_info -> string -> 
  int32 -> int64 * int64 ->
  string option -> Eliom_common.sessgrp
val make_persistent_full_group_name :
  Ocsigen_extensions.request_info -> string -> string option -> Eliom_common.perssessgrp option

val getsessgrp : 
  Eliom_common.sessgrp -> string * (string, Ocsigen_lib.ip_address) Ocsigen_lib.leftright
val getperssessgrp : Eliom_common.perssessgrp -> (string * string)

module type MEMTAB =
  sig
    val add : ?set_max: int -> Eliom_common.sitedata ->
      string -> Eliom_common.sessgrp -> string Ocsigen_cache.Dlist.node
    val remove : 'a Ocsigen_cache.Dlist.node -> unit
    val remove_group : Eliom_common.sessgrp -> unit
    val move :
      ?set_max:int ->
      Eliom_common.sitedata ->
      string Ocsigen_cache.Dlist.node ->
      Eliom_common.sessgrp -> string Ocsigen_cache.Dlist.node
    val up : string Ocsigen_cache.Dlist.node -> unit
    val length : unit -> int
    val set_max : 'a Ocsigen_cache.Dlist.node -> int -> unit
  end

module Serv : MEMTAB
module Data : MEMTAB

module Pers :
  sig
    val find : Eliom_common.perssessgrp option -> string list Lwt.t
    val add : ?set_max: int option ->
      int option -> string -> Eliom_common.perssessgrp option -> string list Lwt.t
    val remove : string -> Eliom_common.perssessgrp option -> unit Lwt.t
    val remove_group : Eliom_common.perssessgrp option -> unit Lwt.t
    val move :
      ?set_max: int option ->
      int option ->
      string ->
      Eliom_common.perssessgrp option ->
      Eliom_common.perssessgrp option ->
      string list Lwt.t
    val up : string -> Eliom_common.perssessgrp option -> unit Lwt.t
    val length : unit -> int Lwt.t
  end
