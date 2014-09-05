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

public class AppWindow : Gtk.ApplicationWindow {

    private Gtk.Toolbar left_toolbar;
    private Gtk.Toolbar right_toolbar;
    private Gtk.Stack left_stack;
    private Gtk.Stack right_stack;

    private Gtk.HeaderBar headerbar;
    private PageContainer page_container;
    private Sidebar sidebar;
    private Gtk.ToolButton unfullscreen_button;
    private bool is_fullscreen = false;

    public Foto.FotoApp app;
    public Foto.Settings settings;

    public signal void fullscreen_event_notify();
    public signal void unfullscreen_event_notify();

    public AppWindow (Foto.FotoApp foto_app) {

        this.app = foto_app;
        set_application (this.app);
        Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;

        this.icon_name = "foto";
        this.title = this.app.app_cmd_name;
        this.window_position = Gtk.WindowPosition.CENTER;
        this.set_default_size (1000, 680);

        build_ui();
        this.show_all();
    }

    private void build_ui() {

        debug("AppWindow building UI\n");

        settings = new Foto.Settings();
        var picdao = PictureDAO.get_instance();

        page_container = new PageContainer();

        if(settings.first_run || picdao.count() == 0) {
            page_container.switch_to_page(PageType.WELCOME_PAGE);
            settings.first_run = false;
        } else {
            page_container.switch_to_page(PageType.LIBRARY_PAGE);
        }

        sidebar = new Sidebar(page_container);

        var thin_panned = new Granite.Widgets.ThinPaned();
        thin_panned.pack1(sidebar, false, false);
        thin_panned.pack2(page_container, true, false);

        headerbar = new Gtk.HeaderBar();
        headerbar.show_close_button = true;
        headerbar.title = _("Photos");
        headerbar.get_style_context ().remove_class ("header-bar");

        left_toolbar = page_container.get_current_page().get_left_toolbar();
        right_toolbar = page_container.get_current_page().get_right_toolbar();
        left_stack = new Gtk.Stack();
        right_stack = new Gtk.Stack();
        left_stack.add_named(left_toolbar, page_container.get_current_page().page_name);
        right_stack.add_named(right_toolbar, page_container.get_current_page().page_name);
        left_stack.set_transition_duration(300);
        left_stack.set_transition_type (Gtk.StackTransitionType.CROSSFADE);
        right_stack.set_transition_duration(300);
        right_stack.set_transition_type (Gtk.StackTransitionType.CROSSFADE);

        headerbar.pack_start(left_stack);
        headerbar.pack_end(right_stack);

        this.set_titlebar (headerbar);
        this.add(thin_panned);

        page_container.page_switched.connect(on_page_switch);

    }

    //this function will update the toolbars
    public void on_page_switch(Page? last_page, Page? current_page) {

        if (right_stack.get_child_by_name (current_page.page_name) == null) {
            debug("Adding toolbar for %s page\n", current_page.page_name);
            left_stack.add_named(current_page.get_left_toolbar(), current_page.page_name);
            right_stack.add_named(current_page.get_right_toolbar(), current_page.page_name);
            current_page.get_left_toolbar().show_all();
            current_page.get_right_toolbar().show_all();
        }

        debug("Switching toolbars to %s\n", current_page.page_name);
        left_stack.set_visible_child_name (current_page.page_name);
        right_stack.set_visible_child_name (current_page.page_name);

        this.show_all();

    }

    public override bool key_press_event (Gdk.EventKey event) {
        switch(event.keyval) {
            case Gdk.Key.F11:
                toggle_fullscreen();
                break;
            case Gdk.Key.Escape:
                unfullscreen();
                break;
            default:
                //propagate the event
                base.key_press_event (event);
                return false;
        }
        return true;
    }

    public void action_new_album() {
        var album_dialog = new Foto.Dialogs.AlbumDialog(null);
        album_dialog.destroy.connect(() =>{
            album_dialog =  null;
        });
    }

    public void action_open_image() {

    }

    public new void fullscreen() {
        base.fullscreen();
        is_fullscreen = true;
        fullscreen_event_notify();
    }

    public new void unfullscreen() {
        base.unfullscreen();
        is_fullscreen = false;
        unfullscreen_event_notify();
    }

    public void toggle_fullscreen() {
        if(is_fullscreen)
            unfullscreen();
        else
            fullscreen();
    }

}