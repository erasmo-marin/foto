project(Foto)
cmake_minimum_required (VERSION 2.8)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake )
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)

#
# Base bits
#
set (CMAKE_C_FLAGS "-ggdb")
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/foto")
set (GETTEXT_PACKAGE "foto")
set (RELEASE_NAME "Photo viewer")
set (VERSION "1.0")
set (VERSION_INFO "Release")


#
# Niceties
#
set (ARCHIVE_NAME foto-${VERSION})
add_custom_target (dist
    COMMAND bzr export --root=${ARCHIVE_NAME} ${CMAKE_BINARY_DIR}/${ARCHIVE_NAME}.tar.bz2
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )

add_custom_target (distcheck
    COMMAND cd ${CMAKE_BINARY_DIR}
    && rm -rf ${ARCHIVE_NAME}
    && tar xf ${ARCHIVE_NAME}.tar.bz2
    && mkdir ${ARCHIVE_NAME}/build
    && cd ${ARCHIVE_NAME}/build
    && cmake -DCMAKE_INSTALL_PREFIX=../install -DGSETTINGS_LOCALINSTALL=ON .. -DCMAKE_MODULE_PATH=/usr/share/cmake
    && make -j8
    && make -j8 install
    && make check
    )
add_dependencies(distcheck dist)

add_custom_target (uninstall "${CMAKE_COMMAND}" -P
  "${CMAKE_SOURCE_DIR}/cmake/uninstall.cmake")


#
# config.h
#

configure_file (${CMAKE_SOURCE_DIR}/config.h.cmake ${CMAKE_BINARY_DIR}/config.h)
add_definitions(-include config.h)


#
# Data
#

file (GLOB _datafiles "${CMAKE_CURRENT_SOURCE_DIR}/data/files/*")
install (FILES ${_datafiles} DESTINATION ${PKGDATADIR}/files)

file (GLOB _imagefiles "${CMAKE_CURRENT_SOURCE_DIR}/data/icons/*")
install (FILES ${_imagefiles} DESTINATION ${PKGDATADIR})

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/foto.desktop DESTINATION /usr/share/applications)

#
# Icons
#

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/foto.svg DESTINATION share/icons/hicolor/scalable/apps/)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/foto-view-edit-symbolic.svg DESTINATION share/icons/hicolor/scalable/actions/)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/foto-last-import-item.png DESTINATION share/icons/hicolor/16x16/categories/)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/foto-camera-item.png DESTINATION share/icons/hicolor/16x16/categories/)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/foto-pictures-item.png DESTINATION share/icons/hicolor/16x16/categories/)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/foto-tag-item.png DESTINATION share/icons/hicolor/16x16/categories/)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/foto-places-item.png DESTINATION share/icons/hicolor/16x16/categories/)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/view-presentation-symbolic.svg DESTINATION share/icons/hicolor/scalable/actions/)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/slideshow-next.png DESTINATION share/icons/hicolor/48x48/actions/)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/slideshow-previous.png DESTINATION share/icons/hicolor/48x48/actions/)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/slideshow-play.png DESTINATION share/icons/hicolor/48x48/actions/)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/slideshow-pause.png DESTINATION share/icons/hicolor/48x48/actions/)

option (ICON_UPDATE "Run gtk-update-icon-cache after the install." ON)
if (ICON_UPDATE)
  install (CODE "message(\"-- Updating icon cache...\")")
  install (CODE "execute_process(COMMAND gtk-update-icon-cache -f -t ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor)")
endif ()


#
# i18n
#

add_subdirectory(po)


#
# SRC
#

find_package(PkgConfig)
pkg_check_modules(DEPS REQUIRED gobject-2.0 glib-2.0 gio-2.0 gtk+-3.0 clutter-gtk-1.0 clutter-1.0 
                                gthread-2.0 granite gee-0.8 sqlite3 gexiv2 libexif champlain-0.12 
                                champlain-gtk-0.12)

add_definitions(${DEPS_CFLAGS})

link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.20.0" MINIMUM)

set(PKG_DEPS gtk+-3.0
             sqlite3
             granite
             gio-2.0 
             gee-0.8
             clutter-gtk-1.0
             clutter-1.0
             gexiv2
             champlain-0.12
             champlain-gtk-0.12
             posix)


set(SRC_FILES       
            src/FotoApp.vala
            src/AppWindow.vala
            src/ViewManager.vala
            src/MainMenu.vala
            src/PageContainer.vala
            src/ViewerWindow.vala

            src/core/ImportJob.vala
            src/core/PictureSorter.vala
            src/core/PictureFilter.vala

            src/core/VO/Album.vala
            src/core/VO/Picture.vala
            src/core/VO/Tag.vala
            src/core/VO/Folder.vala
            src/core/VO/AlbumCollection.vala
            src/core/VO/PictureCollection.vala
            src/core/VO/TagCollection.vala

            src/core/DAO/AlbumDAO.vala
            src/core/DAO/PictureDAO.vala
            src/core/DAO/TagDAO.vala
            src/core/DAO/FolderDAO.vala
            src/core/DAO/Db.vala

            src/core/PhotoFormat/PhotoMetadata.vala
            src/core/PhotoFormat/Photo.vala
            src/core/PhotoFormat/PhotoDriver.vala
            src/core/PhotoFormat/PhotoFormat.vala

            src/dialogs/AlbumDialog.vala
            src/dialogs/PropertiesDialog.vala
            src/dialogs/AddToAlbumDialog.vala

            src/pages/Page.vala
            src/pages/CollectionPage.vala
            src/pages/LibraryPage.vala
            src/pages/WelcomePage.vala
            src/pages/ViewerPage.vala
            src/pages/LastImportedPage.vala
            src/pages/TagPage.vala
            src/pages/AlbumPage.vala
            src/pages/MapPage.vala

            src/sidebar/Sidebar.vala

            src/settings/Settings.vala

            src/slideshow/SlideshowWindow.vala

            src/widgets/DropArea.vala
            src/widgets/LLabel.vala
            src/widgets/CairoPictureWidget.vala
            src/widgets/ZoomSlider.vala
            src/widgets/PicThumb.vala
            src/widgets/ColorRow.vala
            src/widgets/Rating.vala
            src/widgets/ButtonGroup.vala
            src/widgets/ItemSortBar.vala
            src/widgets/ItemSearchBar.vala

            src/util/IconFactory.vala
            src/util/string.vala
            src/util/PixbufUtils.vala
            src/util/CacheUtils.vala
            src/util/ColorTransformation.vala
            src/util/KeyValueMap.vala)


include(ValaPrecompile)
vala_precompile(VALA_C ${SRC_FILES} PACKAGES ${PKG_DEPS}

CUSTOM_VAPIS
    vapi/config.vapi
    vapi/libexif.vapi
OPTIONS
    --thread
    -g
    --debug
    --target-glib=2.32 
    )

add_definitions(${CFLAGS}-lm -Wall -Winit-self -Wwrite-strings -Wunreachable-code -Wstrict-prototypes)
add_executable(foto ${VALA_C})
target_link_libraries(foto ${SQLITE_LIBRARIES} ${CLUTTERGTK_LIBRARIES} -lm)
install(TARGETS foto RUNTIME DESTINATION bin)


#
# GSettings Schema
#
include(GSettings)
add_schema("org.pantheon.Foto.gschema.xml")

#
# doc
#

add_subdirectory (doc)