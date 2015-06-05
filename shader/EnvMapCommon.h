/// @file
/// @brief ���}�b�v�̋��ʒ�`���s���w�b�_�B
/// @author ���[�`�F

#ifndef POSTIBL_SHADER_ENVMAPCOMMON_H
#define POSTIBL_SHADER_ENVMAPCOMMON_H

/// ���}�b�v�e�ʃ����_�����O�ɂ����� near �N���b�v�B
#define POSTIBL_ENVMAP_FACE_NEAR 1.0f

/// ���}�b�v�e�ʃ����_�����O�ɂ����� far �N���b�v�B
#define POSTIBL_ENVMAP_FACE_FAR 65535.0f

/// @brief �e�ʃ����_�����O�p�̃v���W�F�N�V�����}�g���N�X�B
///
/// fov    == ����p 90��
/// aspect == �A�X�y�N�g�� 1.0
///
/// h  == cot(fov/2) == cos(45��)/sin(45��) == +1
/// w  == h / aspect == +1
/// zn == UE4LIKEIBL_ENVMAP_NEAR
/// zf == UE4LIKEIBL_ENVMAP_FAR
///
/// proj == float4x4( w, 0,              0, 0,
///                   0, h,              0, 0,
///                   0, 0,     zf/(zf-zn), 1,
///                   0, 0, -zn*zf/(zf-zn), 0 )
static float4x4 EnvMapFaceProjMatrix =
    float4x4(
        float4(+1, 0, 0, 0),
        float4( 0,+1, 0, 0),
        float4(
            0,
            0,
            (POSTIBL_ENVMAP_FACE_FAR) /
            ((POSTIBL_ENVMAP_FACE_FAR) - (POSTIBL_ENVMAP_FACE_NEAR)),
            1),
        float4(
            0,
            0,
            -(POSTIBL_ENVMAP_FACE_NEAR) *
            (POSTIBL_ENVMAP_FACE_FAR) /
            ((POSTIBL_ENVMAP_FACE_FAR) - (POSTIBL_ENVMAP_FACE_NEAR)),
            0));

/// �e�ʂ̕����x�N�g���B
static float3 EnvMapFaceDirections[6] =
    {
        float3(+1,  0,  0), // +X
        float3(-1,  0,  0), // -X
        float3( 0, +1,  0), // +Y
        float3( 0, -1,  0), // -Y
        float3( 0,  0, +1), // +Z
        float3( 0,  0, -1), // -Z
    };

/// @brief �e�ʃ����_�����O�p�̃r���[�}�g���N�X���쐬����B
/// @param[in] cameraPos �J�����ʒu�B
/// @param[in] face �ʃC���f�b�N�X�B 0 �` 5 �B
/// @return �r���[�}�g���N�X�B
float4x4 MakeEnvMapFaceViewMatrix(uniform float3 cameraPos, uniform int face)
{
    // eye == �J�����ʒu
    // at  == �����_
    // up  == ������x�N�g��
    //
    // zaxis == at - eye
    // xaxis == cross(up, zaxis)
    // yaxis == cross(zaxis, xaxis)
    //
    // trans == float3(-dot(xaxis, eye), -dot(yaxis, eye), -dot(zaxis, eye))
    //
    // view == float4x4( xaxis.x, yaxis.x, zaxis.x, 0,
    //                   xaxis.y, yaxis.y, zaxis.y, 0,
    //                   xaxis.z, yaxis.z, zaxis.z, 0,
    //                   trans.x, trans.y, trans.z, 1 )

    float3 z_axis = EnvMapFaceDirections[face];
    float3 x_axis = float3(abs(z_axis.y) + z_axis.z, 0, -z_axis.x);
    float3 y_axis = float3(0, abs(z_axis.x + z_axis.z), -z_axis.y);

    return
        float4x4(
            float4(x_axis.x, y_axis.x, z_axis.x, 0),
            float4(x_axis.y, y_axis.y, z_axis.y, 0),
            float4(x_axis.z, y_axis.z, z_axis.z, 0),
            float4(
                -dot(x_axis, cameraPos),
                -dot(y_axis, cameraPos),
                -dot(z_axis, cameraPos),
                1));
}

#endif // POSTIBL_SHADER_ENVMAPCOMMON_H
