# Serialize deps packages for valadoc
foreach (pkg ${PKG_DEPS})
    list (APPEND VALADOC_PKG_OPTS "--pkg=${pkg}")
endforeach ()

foreach (src ${SRC_FILES})
    list (APPEND VALADOC_SRC_FILES "${CMAKE_SOURCE_DIR}/${src}")
endforeach ()

# Source files to scan
set (SRC_DIR "${CMAKE_SOURCE_DIR}/src")
set (VAPI_DIR "${CMAKE_SOURCE_DIR}/vapi")
list (APPEND VALADOC_SRC_FILES "${VAPI_DIR}/*.vapi")

set (BASE_VALADOC_COMMAND
    valadoc
    ${VALADOC_PKG_OPTS}
    ${VALADOC_SRC_FILES}
    --internal
    --private
    --force
    --package-name=${PKG_NAME}
    --package-version=${PKG_VERSION}
    --target-glib=2.32)

#########################
# Vala API documentation
#########################

add_custom_target (valadocs)
set (VALA_API_DOC_DIR "${CMAKE_CURRENT_BINARY_DIR}/doc")

add_custom_command (TARGET valadocs COMMAND rm ${CMAKE_CURRENT_BINARY_DIR}/images -R -f)
add_custom_command (TARGET valadocs COMMAND cp ${CMAKE_SOURCE_DIR}/doc/images/ ${CMAKE_CURRENT_BINARY_DIR}/images -R)

add_custom_command (TARGET valadocs COMMAND rm ${VALA_API_DOC_DIR} -R -f) # delete previous files
add_custom_command (TARGET valadocs COMMAND ${BASE_VALADOC_COMMAND} --doclet=html -o ${VALA_API_DOC_DIR})

#########################
# All the documents
#########################

add_custom_target (docs)
add_dependencies (docs valadocs)