parttocompare = participants{parts};
paramName = ['SpecCoeff_', sesscompNameString, 'copx', muscleID{musc}, '_', parttocompare, '_',IDtocompare];

commd = [paramName '=' dirParam, '(strcmp(', dirParam, '.participant, parttocompare), :);'];
eval(commd);

tcommd = [sesscompNameString, 'trialID = unique(', paramName, '.trial);'];
eval(tcommd);

%a = extractfield(s, name)
clparamName = [sesscompNameString, 'cl_copx', muscleID{musc}, '_', parttocompare, '_', IDtocompare];
commdcl = [clparamName, '=copemgcoherenceconfidencelimits.(parttocompare);'];
eval(commdcl);

sizecommd = ['sizeoftrialID = size(', sesscompNameString, 'trialID, 1);'];
eval(sizecommd);

for tria = 1:sizeoftrialID
    trIDcommd = ['trIDtocompare = ', sesscompNameString, 'trialID{tria};'];
    eval(trIDcommd);
    trparamName = [paramName, '_', trIDtocompare];
    commdtr = [trparamName '=', paramName, '(strcmp(', paramName, '.trial, trIDtocompare), :);'];
    eval(commdtr);

    sigstructField = [structdef, mstructdef];
    commdtrcl = [clparamName, '_', trIDtocompare, '=', clparamName, '.(sesscl).(trIDtocompare).(IDtocompare).(sigstructField);'];
    eval(commdtrcl);
    sccommd = ['specCoeff', sesscompNameString, ' = [', trparamName, '{:,5:6} str2double(', trparamName, '{:,7})];'];
    eval(sccommd);
    sessNameplf = [sesscompNameString, 'plf1_', IDtocompare];
    sessNameplv = [sesscompNameString, 'plv1_', IDtocompare];
    if count == 1
        poolcommd = ['[', sesscompNameString, 'plf1,', sesscompNameString, 'plv1]=pool_scf(specCoeff', sesscompNameString, ',', clparamName, '_', trIDtocompare, ');'];
        eval(poolcommd);

    else
        poolcommd1= ['[', sesscompNameString, 'plf1,', sesscompNameString, 'plv1]=pool_scf(specCoeff', sesscompNameString, ',', clparamName, '_', trIDtocompare, ',', sesscompNameString, 'plf1,', sesscompNameString, 'plv1);'];
        eval(poolcommd1);

    end
    if count_sess == 1
        poolcommdsess = ['[', sessNameplf, ',', sessNameplv, ']=pool_scf(specCoeff', sesscompNameString, ',', clparamName, '_', trIDtocompare, ');'];
        eval(poolcommdsess);

    else
        poolcommdsess = ['[', sessNameplf, ',', sessNameplv, ']=pool_scf(specCoeff', sesscompNameString, ',', clparamName, '_', trIDtocompare, ',', sessNameplf, ',', sessNameplv, ');'];
        eval(poolcommdsess);

    end
    count = count + 1;
    count_sess = count_sess + 1;

end

if caseno == 2
    colCount = sess;
elseif caseno == 3 && sess == 3
    colCount = sess - 2;
elseif caseno == 3 && sess == 5
    colCount = sess - 3;
elseif caseno == 5 && sess == 2
    colCount = sess - 1;
elseif caseno == 5 && sess == 5
    colCount = sess - 3;
elseif caseno == 6 && sess == 2
    colCount = sess - 1;
elseif caseno == 6 && sess == 3
    colCount = sess - 1;
end

poolflag1 = 'PAS';
plotcommd1 = ['[Pooled_f_accSess_', sesscompNameString, parttocompare, sigsinv, ', Pooled_cl_accSess_', sesscompNameString, parttocompare, sigsinv, '] = poolandplot_Coherence_HCPC_2019(', sesscompNameString, 'plf1,', sesscompNameString, 'plv1, poolflag1, IDtocompare, muscname, Coherencetype, filesubFolder, pathCompSep,destPath);'];
eval(plotcommd1);
poolflag = 'PWS';
plotcommd = ['[Pooled_f_withSess_', sesscompNameString, parttocompare, IDtocompare, sigsinv, ', Pooled_cl_withSess_', sesscompNameString, parttocompare, IDtocompare, sigsinv, '] = poolandplot_Coherence_HCPC_2019(', sessNameplf, ',', sessNameplv, ', poolflag, IDtocompare, muscname, Coherencetype, filesubFolder, pathCompSep,destPath);'];
eval(plotcommd);
concatcommd = ['Pooled_f_withSess', sesscompNameString, sigsinv, '(:, parts, colCount) = [Pooled_f_withSess_', sesscompNameString, parttocompare, IDtocompare, sigsinv,'(:, 2)];'];
eval(concatcommd);
concatcommd1 = ['Pooled_cl_sig_withSess', sesscompNameString, sigsinv, '(:, parts, colCount) = [Pooled_cl_withSess_', sesscompNameString, parttocompare, IDtocompare, sigsinv, '(:, 2)];'];
eval(concatcommd1);
concatcommd2 = ['Pooled_cl_sig1_withSess', sesscompNameString, sigsinv, '(:, parts, colCount) = [Pooled_cl_withSess_', sesscompNameString, parttocompare, IDtocompare, sigsinv, '(:, 3)];'];
eval(concatcommd2);
concatcommd3 = ['Pooled_f_chisq_withSess', sesscompNameString, sigsinv, '(:, parts, colCount) = [Pooled_f_withSess_', sesscompNameString, parttocompare, IDtocompare, sigsinv,'(:, 3)];'];
eval(concatcommd3);