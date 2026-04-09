package com.family.genealogy.controller;

import com.family.genealogy.common.Result;
import com.family.genealogy.dto.*;
import com.family.genealogy.service.MemberService;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/members")
public class MemberController {

    private final MemberService memberService;

    public MemberController(MemberService memberService) {
        this.memberService = memberService;
    }

    @PostMapping
    public Result<Long> createMember(Authentication authentication,
                                     @Valid @RequestBody MemberCreateRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        Long memberId = memberService.createMember(userId, request);
        return Result.success("添加成功", memberId);
    }

    @PutMapping("/{id}")
    public Result<Void> updateMember(Authentication authentication,
                                     @PathVariable Long id,
                                     @RequestBody MemberUpdateRequest request) {
        Long userId = (Long) authentication.getPrincipal();
        memberService.updateMember(id, request);
        return Result.success("修改成功");
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteMember(Authentication authentication,
                                      @PathVariable Long id) {
        Long userId = (Long) authentication.getPrincipal();
        memberService.deleteMember(id);
        return Result.success("删除成功");
    }

    @GetMapping("/{id}")
    public Result<MemberDetailDTO> getMemberDetail(Authentication authentication,
                                                   @PathVariable Long id) {
        Long userId = (Long) authentication.getPrincipal();
        MemberDetailDTO detail = memberService.getMemberDetail(id);
        return Result.success(detail);
    }

    @GetMapping
    public Result<PageDTO<MemberSimpleDTO>> listMembers(Authentication authentication,
                                                        @RequestParam(required = false) Integer page,
                                                        @RequestParam(required = false) Integer size,
                                                        @RequestParam(required = false) String name,
                                                        @RequestParam(required = false) Integer generation) {
        Long userId = (Long) authentication.getPrincipal();
        PageDTO<MemberSimpleDTO> result = memberService.listMembers(userId, page, size, name, generation);
        return Result.success(result);
    }
}
