import { Response } from 'express';

export const successResponse = (
  res: Response,
  data?: any,
  message: string = 'success',
  statusCode: number = 200,
): Response => {
  return res.status(statusCode).json({
    code: statusCode,
    message,
    data,
  });
};

export const errorResponse = (
  res: Response,
  message: string,
  statusCode: number = 400,
  error?: any,
): Response => {
  return res.status(statusCode).json({
    code: statusCode,
    message,
    ...(error && { error }),
  });
};

export const paginatedResponse = (
  res: Response,
  data: any[],
  total: number,
  page: number,
  pageSize: number,
): Response => {
  return successResponse(res, {
    data,
    pagination: {
      total,
      page,
      pageSize,
      totalPages: Math.ceil(total / pageSize),
    },
  });
};
