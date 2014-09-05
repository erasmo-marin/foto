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

public class Folder : GLib.Object {

    public int id;
    public string folder_path;
    public bool is_import_folder = false;

    public Folder.with_values(int id, string folder_path, bool is_import_folder) {

        this.id = id;
        this.folder_path = folder_path;
        this.is_import_folder = is_import_folder;

    }

}