// Manual conversion
// dxc post_processing.hlsl -T ps_6_0 -spirv -fspv-entrypoint-name=fragment -Fo post_processing.spv

// Vertex output structure
struct FullscreenVertexOutput
{
    float4 position : SV_POSITION;
    float2 uv : TEXCOORD0;
};

// Texture and sampler declaration
[[vk::binding(0, 0)]]
Texture2D screen_texture;
[[vk::binding(1, 0)]]
SamplerState texture_sampler;

// Structure for post-processing settings
// Each element in the cbuffer needs to align to 16 bytes
struct PostProcessSettings
{
    float3 padding;
    float intensity;
};

// Uniform buffer for settings
[[vk::binding(2, 0)]]
cbuffer PostProcessSettingsBuffer
{
    PostProcessSettings settings;
};

// Fragment shader, needs to be called main here for DXC, this will be renamed to fragment if ps_6_0, or similar is selected
float4 main(FullscreenVertexOutput input)
    : SV_TARGET
{
    // Chromatic aberration strength
    float offset_strength = settings.intensity;

    // Sample each color channel with an arbitrary shift
    float4 color = float4(
        screen_texture.Sample(texture_sampler, input.uv + float2(offset_strength, -offset_strength)).r,
        screen_texture.Sample(texture_sampler, input.uv + float2(-offset_strength, 0.0)).g,
        screen_texture.Sample(texture_sampler, input.uv + float2(0.0, offset_strength)).b,
        1.0);

    return color;
}
