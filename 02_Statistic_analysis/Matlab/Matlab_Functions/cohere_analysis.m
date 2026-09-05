function [cohere] = cohere_analysis(all_coherence_data,frequency)

sc = all_coherence_data;

% Update pooled spectral coefficient matrix.                     % Col  1 is count of significant coherence.
plf(:,1) =sc(:,1);                % Col  2 is pooled f11       (2.11) in JNM.
plf(:,2) =sc(:,2);                % Col  3 is pooled f22       (2.11) in JNM.
plf(:,3) =real(sc(:,3));          % Col  4 is pooled Re{f21}   (2.11) in JNM.
plf(:,4) =imag(sc(:,3));

% Update pooled spectral variable structure
coh_f=((plf(:,3).*plf(:,3))+(plf(:,4).*plf(:,4)))./(plf(:,1).*plf(:,2));

% Construct output spectral matrix f.
f(:,1)= frequency;               % Column 1 - frequencies in Hz.
f(:,2)= coh_f;                             % Column 4 - Coherence (Pooled coherency estimate).

cohere = f;

end
