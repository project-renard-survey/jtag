function blocks = find_formatting_info(blocks,pix);

p_width = size(pix,2);
p_height = size(pix,1);

p_ink = [1 1 p_width p_height];
p_ink = seg_snap(pix,p_ink);

%Original page margins
l_marg = p_ink(1);
r_marg = (p_width - p_ink(3));
t_marg = p_ink(2);
b_marg = (p_height - p_ink(4));

bout = [];
for i=1:length(blocks);
    block = blocks(i);

    l = block.rect(1);
    r = block.rect(3);
    t = block.rect(2);
    b = block.rect(4);
    %fprintf('Type=%s',char(block.cname));
    %fprintf(', l=%i, r=%i, l_marg=%i, p_ink(3)=%i, p_width=%i ', ...
    %        l, r, l_marg, p_ink(3), p_width);
    if (abs(l - l_marg) < 10);
        block.align_l = true;
        block.align_r = false;
        block.align_c = false;
        %fprintf('align=left\n');
    elseif (abs(r - p_ink(3)) < 10);
        block.align_r = true;
        block.align_l = false;
        block.align_c = false;
        %fprintf('align=right\n');
    elseif (abs(((l+r)/2) - (p_width/2)) < 20);
        block.align_c = true;
        block.align_r = false;
        block.align_l = false;
        %fprintf('align=center\n');
    else;
        block.align_c = false;
        block.align_r = false;
        block.align_l = true;
        %fprintf('align=left_by_default\n');
    end;

    cn = block.cname;
    block.align_full = false;
    if (strcmp(cn,'text'));
        block.align_full = true;
        block.takefullrow = true;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'authour_list'));
        block.takefullrow = false;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'section_heading'));
        block.takefullrow = true;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'main_title'));
        block.align_c = true;
        block.align_l = false;
        block.align_r = false;
        block.takefullrow = true;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'decoration'));
        block.takefullrow = true;
        block.keepwithnext = false;
        if ((i<length(blocks)) && strcmp('footnote',blocks(i+1).cname));
            block.keepwithnext = true;
            block.sticktobottom = true;
        else;
            block.keepwithnext = false;
            block.sticktobottom = false;
        end;
        block.sticktotop = false;
    elseif (strcmp(cn,'footnote'));
        block.align_full = true;
        block.takefullrow = true;
        block.keepwithnext = false;
        block.sticktobottom = true;
        block.sticktotop = false;
    elseif (strcmp(cn,'abstract'));
        block.align_full = true;
        block.takefullrow = true;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'eq_number'));
        block.takefullrow = false;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'equation'));
        block.takefullrow = false;
        if ((i<length(blocks)) && strcmp('eq_number',blocks(i+1).cname));
            block.keepwithnext = true;
        else;
            block.keepwithnext = false;
        end;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'graph'));
        block.takefullrow = false;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'table'));
        block.takefullrow = false;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'table_caption'));
        block.align_full = true;
        block.takefullrow = false;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'figure_caption'));
        block.align_full = true;
        block.takefullrow = false;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'references'));
        block.takefullrow = true;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'subsection_heading'));
        block.takefullrow = true;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'image'));
        block.takefullrow = false;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'bullet_item'));
        block.takefullrow = true;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'code_block'));
        block.takefullrow = true;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'figure'));
        block.takefullrow = false;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'figure_label'));
        block.takefullrow = false;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'table_label'));
        block.takefullrow = false;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'header'));
        block.takefullrow = true;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = true;
    elseif (strcmp(cn,'editor_list'));
        block.takefullrow = true;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    elseif (strcmp(cn,'pg_number'));
        block.takefullrow = true;
        block.keepwithnext = false;
        block.sticktotop = (abs(t - t_marg) < 20);
        block.sticktobottom = (abs(b - pink(4)));
    elseif (strcmp(cn,'footer'));
        block.takefullrow = true;
        block.keepwithnext = false;
        block.sticktobottom = true;
        block.sticktotop = false;
    else
        block.takefullrow = true;
        block.keepwithnext = false;
        block.sticktobottom = false;
        block.sticktotop = false;
    end;
    bout = [bout;block];
end;

blocks = bout;
