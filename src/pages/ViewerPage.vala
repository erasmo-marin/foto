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

using Foto.Widgets;

/* A Page that shows an image, allow setting
 * image collections, navigation between image 
 * collections items and the asociated toolbars.
 */
public class ViewerPage : Page {

    private Foto.Widgets.PictureWidget image_widget;
    private Gtk.ActionGroup main_actions;
    private Gtk.UIManager ui;
    private Foto.Widgets.ZoomSlider slider;
    private PictureCollection collection;
    private Picture current_picture;
    private Gtk.Menu contextual_menu;
    private Gtk.Image histogram;
    private PageType parent;
    private bool overlay_widgets_hover = false;
  

    public ViewerPage(PageContainer container) {
        base(PageType.VIEWER_PAGE.to_string(), container);
        image_widget = new Foto.Widgets.PictureWidget();
        this.add(image_widget);
        init_toolbars();
        build_overlay_widgets();
        this.show_all();

        //It must go here because of preventing G_TYPE_CHECK_INSTANCE() warning
        image_widget.scale_changed.connect((scale)=> {
            slider.set_value(scale);
        });

        slider.zoom_changed.connect((scale)=>{
            image_widget.set_scale(scale);
        });

        image_widget.right_clicked.connect(() => {
            debug("Right clicked");
            contextual_menu.popup(null, null, null, 1, 0);
        });

        image_widget.double_clicked.connect(()=> {
            this.container.switch_to_page(parent);
        });

        container.page_switched.connect((last_page, current_page)=>{
            if (last_page != null && current_page.page_name == this.page_name) {
                parent = PageType.parse(last_page.page_name);
                debug("ViewerPage.parent = " + last_page.page_name);
            }
        });


        //show/hide overlay widgets when mouse enter/leaves
        eventbox.enter_notify_event.connect (() => {
            this.show_overlay_widgets();
            return false;
        });

        eventbox.leave_notify_event.connect ((event) => {

            debug("ViewerPage.leave_notify_event event.x=%f, event.y=%f", event.x, event.y);

            //FIXME check if pointer is outside the allocated area. When pointer is over
            //an overlay widget, it triggers a leave event.
            //Using 5px as a threshold, but it should be 0.
            //For some reason the leave event is trigged before leaving the widget sometimes.
            if(event.x < 5 || event.y < 5 || event.x > (get_allocated_width()-5) || event.y > (get_allocated_height()-5))
                this.hide_overlay_widgets();
            //grab focus on leave event, because 
            //sometimes it loose it, not sure why
            this.grab_focus();
            return false;
        });
    }

    private void build_overlay_widgets () {
        //Next button
        var next_btn = buid_overlay_button ("slideshow-next", Gtk.IconSize.DIALOG);
        this.add_overlay(next_btn);
        next_btn.halign = Gtk.Align.END;
        next_btn.valign = Gtk.Align.CENTER;
        next_btn.margin_right = 12;
        next_btn.clicked.connect(action_go_next);
        next_btn.tooltip_text = _("Show next photo");

        //Previous button
        var prev_btn = buid_overlay_button ("slideshow-previous", Gtk.IconSize.DIALOG);
        this.add_overlay(prev_btn);
        prev_btn.halign = Gtk.Align.START;
        prev_btn.valign = Gtk.Align.CENTER;
        prev_btn.margin_left = 12;
        prev_btn.clicked.connect(action_go_previous);
        prev_btn.tooltip_text = _("Show previous photo");
    }

    public override void init_toolbars() {

        //ui
        main_actions = new Gtk.ActionGroup ("MainActionGroup");
        main_actions.add_actions (main_entries, this);

        ui = new Gtk.UIManager ();

        try {
            ui.add_ui_from_string (ui_string, -1);
        } catch (Error e) {
            error ("Couldn't load the UI: %s", e.message);
        }

        ui.insert_action_group(main_actions, -1);

        //rotate
        var rotate_group = new ToolButtonGroup();
        rotate_group.margin_top = 5;
        rotate_group.margin_bottom = 5;
        rotate_group.margin_right = 10;

        var rotate_left_btn = rotate_group.append_button_with_icon ("object-rotate-left-symbolic", Gtk.IconSize.MENU);
        rotate_left_btn.tooltip_text = _("Rotate to the left");

        var rotate_right_btn = rotate_group.append_button_with_icon ("object-rotate-right-symbolic", Gtk.IconSize.MENU);
        rotate_right_btn.tooltip_text = _("Rotate to the right");

        //view group
        var edit_group = new ToolButtonGroup();
        edit_group.margin_top = 5;
        edit_group.margin_bottom = 5;

        var best_fit_btn = edit_group.append_button_with_icon ("zoom-fit-best-symbolic", Gtk.IconSize.MENU);
        best_fit_btn.tooltip_text = _("Adjust the photo at the available space");

        var zoom_original_btn = edit_group.append_button_with_icon ("zoom-original-symbolic", Gtk.IconSize.MENU);
        zoom_original_btn.tooltip_text = _("Set the photo at the original scale");

        var slideshow_btn = edit_group.append_button_with_icon ("view-presentation-symbolic", Gtk.IconSize.MENU);
        rotate_right_btn.tooltip_text = _("Start slideshow");

        //toolbars
        left_toolbar = new Gtk.Toolbar();
        right_toolbar = new Gtk.Toolbar();

        //left toolbar items
        left_toolbar.add(rotate_group);
        left_toolbar.add(edit_group);

        slider = new Foto.Widgets.ZoomSlider();
        right_toolbar.add(slider);

        //style
        left_toolbar.get_style_context().remove_class ("toolbar");
        right_toolbar.get_style_context().remove_class ("toolbar");
        left_toolbar.set_icon_size (Gtk.IconSize.SMALL_TOOLBAR);
        right_toolbar.set_icon_size (Gtk.IconSize.SMALL_TOOLBAR);

        //contextual menu
        contextual_menu = ui.get_widget ("/ContextualMenu") as Gtk.Menu;

        //signals
        best_fit_btn.clicked.connect(action_zoom_fit);
        slideshow_btn.clicked.connect(action_slideshow);
        zoom_original_btn.clicked.connect(()=>{
            image_widget.set_scale(1);
        });
        rotate_left_btn.clicked.connect(()=>{
            image_widget.rotate(RotationType.LEFT);
        });
        rotate_right_btn.clicked.connect(()=>{
            image_widget.rotate(RotationType.RIGHT);
        });

    }

    public void set_collection (PictureCollection collection, int index_first_item) {
        this.collection = collection;
        current_picture = collection.get(index_first_item);
        image_widget.set_image(current_picture.file_path);
    }

    public void set_picture (Picture picture) {
        current_picture = picture;
        image_widget.set_image(current_picture.file_path);
    }

    public void set_parent_page (PageType parent) {
        this.parent = parent;
    }

    private void action_go_previous () {
        if(collection == null || collection.size<1)
            return;

        int index = collection.index_of(current_picture);
        debug("ViewerPage.action_go_previous index: %d", index);

        if((index-1) < 0)
            index = collection.size - 1;
        else
            index--;
        set_picture(collection.get(index));       
    }

    private void action_go_next () {
        if(collection == null || collection.size<1)
            return;

        int index = collection.index_of(current_picture);
        debug("ViewerPage.action_go_next index: %d", index);

        if((index+1) >= collection.size)
            index = 0;
        else
            index++;
        set_picture(collection.get(index));
    }

    private void action_slideshow() {

        var slide = new SlideshowWindow(collection, collection.index_of(current_picture));

    }

    public override bool key_press_event (Gdk.EventKey event) {
        switch(event.keyval) {
            case Gdk.Key.Left:
                action_go_previous();
                break;
            case Gdk.Key.Right:
                action_go_next();
                break;
            default:
                return false;
        }
        return true;
    }

    private void action_zoom_fit() {
        image_widget.set_best_fit(true);
    }

    private void action_set_as_wallpaper() {
        GLib.Settings settings = new GLib.Settings ("org.gnome.desktop.background");
		settings.set_string ("picture-uri", "file://" + current_picture.file_path);
    }

    private void action_properties() {
        var dialog = new Foto.Dialogs.PropertiesDialog(current_picture, this);
    }

    private Gtk.Button buid_overlay_button (string icon_name, Gtk.IconSize size) {
        var button = new Gtk.Button.from_icon_name (icon_name, size);
        button.get_style_context().remove_class ("button");
        Gdk.RGBA transparent = {0.0,0.0,0.0,0.0};
        button.override_background_color (Gtk.StateFlags.NORMAL, transparent);
        return button;
    }


    const string ui_string = """
            <ui>
                <popup name="ContextualMenu" action="ContextualMenuAction">
                      <menuitem name="SetAsWallpaper" action="SetAsWallpaperAction" />
                      <menuitem name="Properties" action="PropertiesAction" />
                      <placeholder name="ContextualMenuAdditions" />
                </popup>
            </ui>""";

    static const Gtk.ActionEntry[] main_entries = {
                { "SetAsWallpaperAction", null, "Set photo as Wallpaper",
                  null, null,
                  action_set_as_wallpaper },
                { "PropertiesAction", null, "Properties",
                  null, null,
                  action_properties }
            };

}