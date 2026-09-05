%% pooledcopemgCoherenceScript_HCPC_2022.m

sigstructField = [structdef, '_', mstructdef]; % CoP-muscle comparison: e.g. Copx_SOL_R

% Load trial
trIDtocompare = cell2mat(unique(SpecCoeff_parts.(sesscompNameString).(structdef).(muscleID{musc}).(parttocompare).(IDtocompare(5:end)).trial));
sizeoftrialID = size(trIDtocompare, 1);

for trial = 1:sizeoftrialID

    % Get statistical Cl data for current participant and condition and CoP-muscle comparison
    Cl.(sesscompNameString).(structdef).(muscleID{musc}).(parttocompare).(IDtocompare(5:end)) = copemgcoherenceconfidencelimits.(parttocompare).(sesscl).(trIDtocompare(trial,:)).(IDtocompare).(sigstructField);

    % Save participant data for current trial in struct
    SpecCoeff_pool.(sesscompNameString) = cell2mat(SpecCoeff_parts.(sesscompNameString).(structdef).(muscleID{musc}).(parttocompare).(IDtocompare(5:end)){:,5:7});
    % Pooling all trials for one CoP-muscle comparison together
    if count == 1 % Start with first participant
        [plf1.(sesscompNameString), plv1.(sesscompNameString)] = pool_scf(SpecCoeff_pool.(sesscompNameString), Cl.(sesscompNameString).(structdef).(muscleID{musc}).(parttocompare).(IDtocompare(5:end)));
    else % Pool together for all following participants
        [plf1.(sesscompNameString), plv1.(sesscompNameString)] = pool_scf(SpecCoeff_pool.(sesscompNameString), Cl.(sesscompNameString).(structdef).(muscleID{musc}).(parttocompare).(IDtocompare(5:end)), plf1.(sesscompNameString), plv1.(sesscompNameString));
    end

    % Pooling all trials for each condition of one CoP-muscle comparison together (e.g. only for EC trial)
    if count_sess == 1 % Start with first participant
        [plf1_sess.(sesscompNameString).(IDtocompare(5:end)), plv1_sess.(sesscompNameString).(IDtocompare(5:end))] = pool_scf(SpecCoeff_pool.(sesscompNameString), Cl.(sesscompNameString).(structdef).(muscleID{musc}).(parttocompare).(IDtocompare(5:end)));
    else % Pool together for all following participants
        [plf1_sess.(sesscompNameString).(IDtocompare(5:end)), plv1_sess.(sesscompNameString).(IDtocompare(5:end))] = pool_scf(SpecCoeff_pool.(sesscompNameString), Cl.(sesscompNameString).(structdef).(muscleID{musc}).(parttocompare).(IDtocompare(5:end)), plf1_sess.(sesscompNameString).(IDtocompare(5:end)), plv1_sess.(sesscompNameString).(IDtocompare(5:end)));
    end

    count = count + 1;
    count_sess = count_sess + 1;
end

% Adjustments based on specific case and session conditions
if caseno == 1
    if any(sess == [1, 2, 3])
        colCount = sess;
    elseif sess == 5
        colCount = 5-1;
    end
elseif caseno == 2
    colCount = sess;
elseif caseno == 3 && any(sess == [3, 5])
    colCount = sess - 2;
elseif caseno == 5 && any(sess == [2, 5])
    if sess == 2
        colCount = sess - 1;
    elseif sess == 5
        colCount = 5-3;
    end
elseif caseno == 6 && any(sess == [2, 3])
    colCount = sess - 1;
end

% Pool and plot CoP-muscle coherences
%whole pool_scf function needs to be run at least 2 times (once with all the inputs) that the following functions work
if count > 2 && count_sess >2

    poolflag1 = 'PAS';
    [Pooled_f.accSess.(sesscompNameString).(parttocompare).(structdef).(muscleID{musc}), Pooled_cl.accSess.(sesscompNameString).(parttocompare).(structdef).(muscleID{musc})] = pooledPlot_Coherence(plf1.(sesscompNameString), plv1.(sesscompNameString), poolflag1, IDtocompare, muscname, Coherencetype, filesubFolder, filesep, destPath);

    poolflag = 'PWS';
    [Pooled_f.withSess.(sesscompNameString).(parttocompare).(IDtocompare(5:end)).(structdef).(muscleID{musc}), Pooled_cl.withSess.(sesscompNameString).(parttocompare).(IDtocompare(5:end)).(structdef).(muscleID{musc})] = pooledPlot_Coherence(plf1_sess.(sesscompNameString).(IDtocompare(5:end)), plv1_sess.(sesscompNameString).(IDtocompare(5:end)), poolflag, IDtocompare, muscname, Coherencetype, filesubFolder, filesep, destPath);

    % Save pooled columns in structs
    Pooled_f_concat.withSess.(sesscompNameString).(structdef).(muscleID{musc})(:, parts, colCount) = Pooled_f.withSess.(sesscompNameString).(parttocompare).(IDtocompare(5:end)).(structdef).(muscleID{musc})(:,2);
    Pooled_cl_concat.sig_withSess.(sesscompNameString).(structdef).(muscleID{musc})(:, parts, colCount) = Pooled_cl.withSess.(sesscompNameString).(parttocompare).(IDtocompare(5:end)).(structdef).(muscleID{musc})(:,2);
    Pooled_cl_concat.sig1_withSess.(sesscompNameString).(structdef).(muscleID{musc})(:, parts, colCount) = Pooled_cl.withSess.(sesscompNameString).(parttocompare).(IDtocompare(5:end)).(structdef).(muscleID{musc})(:,3);
    Pooled_f_concat.chisq_withSess.(sesscompNameString).(structdef).(muscleID{musc})(:, parts, colCount) = Pooled_f.withSess.(sesscompNameString).(parttocompare).(IDtocompare(5:end)).(structdef).(muscleID{musc})(:,3);
end
