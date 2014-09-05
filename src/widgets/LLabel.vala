// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013-2014 Foto Developers (http://launchpad.net/foto)
 *
 * This software is licensed under the GNU General Public License
 * (version 3 or later). See the COPYING file in this distribution.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this software; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Erasmo Marín <erasmo.marin@gmail.com>
 */

namespace Foto.Widgets{
//Useful to create labels faster
public class LLabel : Gtk.Label{
    public LLabel (string? label){
        if(label == null)
            label = " ";
        this.set_halign (Gtk.Align.START);
        this.label = label;
    }
    public LLabel.indent (string? label){
        this (label);
        this.margin_left = 10;
    }
    public LLabel.markup_center (string? label){
        this.set_halign (Gtk.Align.CENTER);
        this.use_markup = true;
        this.label = label;
    }
    public LLabel.markup (string? label){
        this (label);
        this.use_markup = true;
    }
    public LLabel.right (string? label){
        this.set_halign (Gtk.Align.END);
        this.label = label;
    }
    public LLabel.right_with_markup (string? label){
        this.set_halign (Gtk.Align.END);
        this.use_markup = true;
        this.label = label;
    }
}
}