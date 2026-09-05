function COPea = ellipse(x,y)

    % Number of points
    n = length(x);

    % Calculate the covariance matrix
    covariance_matrix = cov(x, y); % x/x

    % Extract standard deviations and covariance
    Sx = sqrt(covariance_matrix(1,1));
    Sy = sqrt(covariance_matrix(2,2));
    Sxy = covariance_matrix(1,2);

    % Calculate the semi-major and semi-minor axes
    lambda1 = (Sx^2 + Sy^2)/2 + sqrt(((Sx^2 - Sy^2)/2)^2 + Sxy^2);
    lambda2 = (Sx^2 + Sy^2)/2 - sqrt(((Sx^2 - Sy^2)/2)^2 + Sxy^2);

    % Calculate the area of the 95% confidence ellipse
    % 3.841 corresponds to the chi-squared value for 95% confidence for 2 degrees of freedom
    COPea = pi * sqrt(lambda1) * sqrt(lambda2) * sqrt(3.841);

end
