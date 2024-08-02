const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const lib = b.addStaticLibrary(.{
        .name = "zglfw",
        .root_source_file = b.path("src/glfw.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "sample",
        .root_source_file = b.path("src/sample.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    const module_export = b.addModule("glfw", .{
        .root_source_file = b.path("src/glfw.zig"),
        .target = target,
    });

    inline for ([_]*std.Build.Module{ &lib.root_module, &exe.root_module, module_export }) |m| {
        m.linkSystemLibrary("glfw", .{});
        m.link_libc = true;
    }

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
