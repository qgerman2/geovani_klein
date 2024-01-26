function [Q] = body_a_inercial_matriz(phi, theta, psi)
    m_psi   = [ cos(psi)  , 0         , -sin(psi)  ;
                0         , 1         , 0          ;
                sin(psi)  , 0         , cos(psi)   ];

    m_theta = [ 1         , 0         , 0;
                0         , cos(theta), -sin(theta);
                0         , sin(theta), cos(theta) ];

    m_phi   = [ cos(phi)  , sin(phi)  , 0          ;
               -sin(phi)  , cos(phi)  , 0          ;
                0         , 0         , 1          ];

    Q = m_psi * m_theta * m_phi;
end