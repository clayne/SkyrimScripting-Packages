package("champollion")
    set_homepage("https://github.com/Orvid/Champollion")
    set_description("A description for Champollion")
    add_urls("https://github.com/Orvid/Champollion.git")
    on_install(function(package)
        import("package.tools.cmake").install(package, {"-DCHAMPOLLION_STATIC_LIBRARY=ON"})
    end)
