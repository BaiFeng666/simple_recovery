workspace "simple-recovery"
  architecture "x64"
  startproject "simple-recovery"

  configurations
  {
    "Debug",
    "Release",
    "Dist"
  }

  outputdir = "%{cfg.buildcfg}"

  IncludeDir = {}
  IncludeDir["fmtlib"] = "vendor/fmtlib/include"
  IncludeDir["json"] = "vendor/json/single_include"
  IncludeDir["MinHook"] = "vendor/MinHook/include"
  IncludeDir["ImGui"] = "vendor/ImGui"
  IncludeDir["ImGuiImpl"] = "vendor/ImGui/examples"
  IncludeDir["spdlog"] = "vendor/spdlog/include"
  
  CppVersion = "C++17"
  MsvcToolset = "v143"
  WindowsSdkVersion = "10.0"
  
  function DeclareMSVCOptions()
    filter "system:windows"
    staticruntime "Off"
	floatingpoint "Fast"
    systemversion (WindowsSdkVersion)
    toolset (MsvcToolset)
    cppdialect (CppVersion)

    defines
    {
      "_CRT_SECURE_NO_WARNINGS",
      "NOMINMAX",
      "WIN32_LEAN_AND_MEAN",
      "_WIN32_WINNT=0x601" -- Support Windows 7
    }
    
    disablewarnings
    {
      "4100", -- C4100: unreferenced formal parameter
      "4201", -- C4201: nameless struct/union
      "4307", -- C4307: integral constant overflow
      "4996", -- C4996: deprecated in C++17
      "4244"
    }
  end
  
  function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
  end
   
  function DeclareDebugOptions()
    filter "configurations:Debug"
      defines { "_DEBUG" }
      symbols "On"
    filter "not configurations:Debug"
      defines { "NDEBUG" }
  end
   
  project "ImGui"
    location "vendor/%{prj.name}"
    kind "StaticLib"
    language "C++"

    targetdir ("bin/lib/" .. outputdir)
    objdir ("bin/lib/int/" .. outputdir .. "/%{prj.name}")
    
    files
    {
      "vendor/%{prj.name}/imgui.cpp",
      "vendor/%{prj.name}/imgui_demo.cpp",
      "vendor/%{prj.name}/imgui_draw.cpp",
      "vendor/%{prj.name}/imgui_tables.cpp",
      "vendor/%{prj.name}/imgui_widgets.cpp",
      "vendor/%{prj.name}/misc/cpp/imgui_stdlib.cpp",
      "vendor/%{prj.name}/backends/imgui_impl_dx11.cpp",
      "vendor/%{prj.name}/backends/imgui_impl_win32.cpp"
    }

    includedirs
    {
      "vendor/%{prj.name}"
    }

    DeclareMSVCOptions()
    DeclareDebugOptions()

  project "fmtlib"
    location "vendor/%{prj.name}"
    kind "StaticLib"
    language "C++"

    targetdir ("bin/lib/" .. outputdir)
    objdir ("bin/lib/int/" .. outputdir .. "/%{prj.name}")

    files
    {
      "vendor/%{prj.name}/include/**.h",
      "vendor/%{prj.name}/src/format.cc",
      "vendor/%{prj.name}/src/os.cc"
    }

    includedirs
    {
      "vendor/%{prj.name}/include"
    }

    DeclareMSVCOptions()
    DeclareDebugOptions()

  project "MinHook"
    location "vendor/%{prj.name}"
    kind "StaticLib"
    language "C"

    targetdir ("bin/lib/" .. outputdir)
    objdir ("bin/lib/int/" .. outputdir .. "/%{prj.name}")

    files
    {
      "vendor/%{prj.name}/include/**.h",
      "vendor/%{prj.name}/src/**.h",
      "vendor/%{prj.name}/src/**.c"
    }

    DeclareMSVCOptions()
    DeclareDebugOptions()

  project "simple-recovery"
    location "simple-recovery"
    kind "SharedLib"
    language "C++"

    targetdir ("bin/" .. outputdir)
    objdir ("bin/int/" .. outputdir .. "/%{prj.name}")

    PrecompiledHeaderInclude = "common.hpp"
    PrecompiledHeaderSource = "%{prj.name}/src/common.cpp"
 
    files
    {
      "%{prj.name}/src/**.hpp",
      "%{prj.name}/src/**.h",
      "%{prj.name}/src/**.cpp",
      "%{prj.name}/src/**.asm"
    }

    includedirs
    {
      "%{IncludeDir.fmtlib}",
      "%{IncludeDir.json}",
      "%{IncludeDir.MinHook}",
      "%{IncludeDir.ImGui}",
      "%{IncludeDir.ImGuiImpl}",
      "%{prj.name}/src"
    }

    libdirs
    {
      "bin/lib"
    }

    links
    {
      "fmtlib",
      "MinHook",
      "ImGui"
    }

    pchheader "%{PrecompiledHeaderInclude}"
    pchsource "%{PrecompiledHeaderSource}"

    forceincludes
    {
      "%{PrecompiledHeaderInclude}"
    }

    DeclareMSVCOptions()
    DeclareDebugOptions()

    flags { "NoImportLib", "Maps" }

    filter "configurations:Debug"
	  flags { "LinkTimeOptimization", "MultiProcessorCompile" }
	  editandcontinue "Off"
      defines { "BIGBASEV2_DEBUG" }

    filter "configurations:Release"
	  flags { "LinkTimeOptimization", "NoManifest", "MultiProcessorCompile" }
      defines { "BIGBASEV2_RELEASE" }
      optimize "speed"
    filter "configurations:Dist"
      flags { "LinkTimeOptimization", "FatalWarnings", "NoManifest", "MultiProcessorCompile" }
      defines { "BIGBASEV2_DIST" }
      optimize "speed"

  project "simple-recovery-injector"
      kind "ConsoleApp"
      language "C++"
      location "simple-recovery-injector"

      characterset ("MBCS")

      targetdir ("bin/%{cfg.buildcfg}")
      objdir ("bin/obj/%{cfg.buildcfg}/%{prj.name}")
   
      PrecompiledHeaderInclude = "common.hpp"
      PrecompiledHeaderSource = "%{prj.name}/src/common.cpp"
      
      includedirs
      {
        "%{IncludeDir.ImGui}",
        "%{IncludeDir.ImGuiImpl}",
        "%{IncludeDir.ImGuiCpp}",
        "%{IncludeDir.spdlog}",
        "%{prj.name}/src"
      }
   
      links
      {
        "ImGui"
      }
   
      files
      {
        "%{prj.name}/src/**.hpp",
        "%{prj.name}/src/**.h",
        "%{prj.name}/src/**.cpp"
      }
      
      filter "configurations:Debug"
         defines { "DEBUG" }
         symbols "On"
   
      filter "configurations:Release"
         defines { "NDEBUG" }
         optimize "On"

    DeclareMSVCOptions()
    DeclareDebugOptions()