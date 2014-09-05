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

public abstract class Page : Gtk.Box {

    public string page_name;

    protected ItemSearchBar search_bar;
    protected ItemSortBar sort_bar;
    protected Gtk.ScrolledWindow content;
    protected Gtk.Overlay overlay;
    protected Gee.ArrayList<Gtk.Widget> overlay_widgets;
    protected Gtk.EventBox eventbox;

    private Gtk.ToolButton add_to_album_btn;
    private Gtk.ToolButton remove_selection_btn;
    private Gtk.ToolButton unselect_btn;

    protected PageContainer container;
    protected Gtk.Toolbar left_toolbar = new Gtk.Toolbar();
    protected Gtk.Toolbar right_toolbar = new Gtk.Toolbar();

    public Page (string page_name, PageContainer container) {

        GLib.Object (orientation: Gtk.Orientation.VERTICAL);

        eventbox = new Gtk.EventBox();
        eventbox.add_events (Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK
                 | Gdk.EventMask.POINTER_MOTION_MASK | Gdk.EventMask.POINTER_MOTION_HINT_MASK
                 | Gdk.EventMask.BUTTON_MOTION_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK
                 | Gdk.EventMask.SCROLL_MASK | Gdk.EventMask.SMOOTH_SCROLL_MASK
                 | Gdk.EventMask.ENTER_NOTIFY_MASK);

        overlay = new Gtk.Overlay();
        content = new Gtk.ScrolledWindow(null, null);
        sort_bar = new ItemSortBar();
        search_bar = new ItemSearchBar();
        overlay_widgets = new Gee.ArrayList<Gtk.Widget>();

        eventbox.add(content);
        overlay.add(eventbox);
        pack_start(sort_bar, false, false, 0);
        pack_start(search_bar, false, false, 0);
        pack_end(overlay, true, true, 0);

        //fix shadow problem in elementary theme
        sort_bar.get_style_context ().remove_class ("search-bar");
        search_bar.get_style_context ().remove_class ("search-bar");

        this.page_name = page_name;
        this.container = container;
        this.set_can_focus(true);
        init_toolbars();
    }

    //wrapper functions
    public new void add(Gtk.Widget widget) {
        content.add(widget);
        //content.get_child().set_shadow_type(Gtk.ShadowType.NONE);
    }

    public void add_overlay(Gtk.Widget widget) {
        overlay_widgets.add(widget);
        overlay.add_overlay(widget);
    }

    protected void hide_overlay_widgets() {
        foreach(Gtk.Widget widget in overlay_widgets)
            widget.hide();
    }

    protected void show_overlay_widgets() {
        foreach(Gtk.Widget widget in overlay_widgets)
            widget.show();
    }

    public new void add_with_viewport(Gtk.Widget widget) {
        content.add(widget);
    }

    public void set_policy (Gtk.PolicyType hscrollbar_policy, Gtk.PolicyType vscrollbar_policy) {
        content.set_policy(hscrollbar_policy, vscrollbar_policy);
    }

    public void set_vadjustment (Gtk.Adjustment vadjustment) {
        content.set_vadjustment (vadjustment);
    }

    public void set_hadjustment (Gtk.Adjustment hadjustment) {
        content.set_hadjustment (hadjustment);
    }

    public Gtk.Adjustment get_vadjustment () {
        return content.get_vadjustment ();
    }

    public Gtk.Adjustment get_hadjustment () {
        return content.get_hadjustment ();
    }

    public Gtk.Widget? get_child() {
        return content.get_child();
    }

    public void show_sort_bar() {
        search_bar.set_search_mode(false);
        sort_bar.set_search_mode(true);
    }

    public void show_search_bar() {
        sort_bar.set_search_mode(false);
        search_bar.set_search_mode(true);
    }


    public virtual void init_toolbars() {
        left_toolbar.get_style_context().remove_class ("toolbar");
        right_toolbar.get_style_context().remove_class ("toolbar");
        left_toolbar.set_icon_size (Gtk.IconSize.SMALL_TOOLBAR);
        right_toolbar.set_icon_size (Gtk.IconSize.SMALL_TOOLBAR);
    }

    public Gtk.Toolbar get_left_toolbar() {
        return left_toolbar;
    }

    public Gtk.Toolbar get_right_toolbar() {
        return right_toolbar;
    }

    public ItemSortBar get_sort_bar() {
        return this.sort_bar;
    }

}