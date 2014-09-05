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

public class PageContainer : Gtk.Stack {

    ViewManager view_manager;
    Page current_page;
    Page last_page;

    public signal void page_switched(Page? last_page, Page? current_page);


    public PageContainer() {
        view_manager = new ViewManager(this);
        this.set_transition_duration(500);
        this.set_transition_type (Gtk.StackTransitionType.CROSSFADE);
    }

    public void switch_to_page(PageType page_type) {

        last_page = current_page;
        current_page = view_manager.get_page(page_type);

        foreach(Gtk.Widget widget in this.get_children()) {
            if (widget == current_page) {
                this.set_visible_child(current_page);
                current_page.show_all();
                current_page.grab_focus();
                page_switched(last_page, current_page);
                return;
            }                
        }
        this.add(current_page);
        current_page.show_all();
        current_page.grab_focus();
        this.set_visible_child(current_page);
        page_switched(last_page, current_page);
    }

    public Page? get_current_page() {
        return current_page;
    }

    public Page get_page(PageType page_type) {
        return view_manager.get_page(page_type);
    }

}