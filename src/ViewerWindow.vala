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

public class ViewerWindow : Gtk.ApplicationWindow {

    private Gtk.Toolbar left_toolbar;
    private Gtk.Toolbar right_toolbar;
    private Gtk.Stack left_stack;
    private Gtk.Stack right_stack;
    private PictureCollection collection;

    private Gtk.HeaderBar headerbar;
    private PageContainer page_container;
    private bool is_fullscreen = false;

    public Foto.FotoApp app;
    public Foto.Settings settings;

    public signal void fullscreen_event_notify();
    public signal void unfullscreen_event_notify();

    public ViewerWindow (Foto.FotoApp foto_app, PictureCollection collection) {

        this.app = foto_app;
        this.collection = collection;
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
        page_container.switch_to_page(PageType.VIEWER_PAGE);
        var viewer_page = (page_container.get_current_page() as ViewerPage);
        viewer_page.set_collection (collection, 0);

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
        this.add(page_container);
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