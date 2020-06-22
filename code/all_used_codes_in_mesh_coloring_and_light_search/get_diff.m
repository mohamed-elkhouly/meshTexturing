function fin_diff_Y=get_diff(Y)
Y=Y;
Y_flipped=Y';
diff_Y=diff([Y(1,:);Y]);
diff_Y_flipped=diff([Y_flipped(1,:);Y_flipped]);
fin_diff_Y=diff_Y+diff_Y_flipped' ;